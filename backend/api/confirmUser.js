import { v4 as uuidv4 } from 'uuid';
import admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

let pendingUsers = new Map(); // Debe ser compartido o usar base de datos real en producción

export default async function handler(req, res) {
  if (req.method === 'GET') {
    const { userId, action } = req.query;
    if (!userId || !action) {
      return res.status(400).send('Faltan parámetros');
    }

    const userData = pendingUsers.get(userId);
    if (!userData) {
      return res.status(404).send('Usuario no encontrado o ya procesado');
    }

    if (action === 'approve') {
      try {
        // Crear usuario en Firebase Auth
        const userRecord = await admin.auth().createUser({
          email: userData.email,
          password: userData.password,
          displayName: `${userData.nombre} ${userData.apellido || ''}`,
        });

        // Guardar datos adicionales en Firestore
        await admin.firestore().collection('users').doc(userRecord.uid).set({
          email: userData.email,
          role: userData.role,
          nombre: userData.nombre,
          apellido: userData.apellido,
          telefono: userData.telefono,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        pendingUsers.delete(userId);

        return res.status(200).send('Usuario aprobado y creado exitosamente');
      } catch (error) {
        console.error('Error creando usuario:', error);
        return res.status(500).send('Error creando usuario');
      }
    } else if (action === 'reject') {
      pendingUsers.delete(userId);
      return res.status(200).send('Usuario rechazado y eliminado');
    } else {
      return res.status(400).send('Acción inválida');
    }
  } else {
    res.setHeader('Allow', ['GET']);
    res.status(405).end(`Método ${req.method} no permitido`);
  }
}
