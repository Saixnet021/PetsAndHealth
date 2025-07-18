import express from 'express';
import nodemailer from 'nodemailer';
import { v4 as uuidv4 } from 'uuid';
import admin from 'firebase-admin';

const app = express();
app.use(express.json());

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

const pendingUsers = new Map(); // userId -> userData

// Configura tu transporte SMTP o servicio de email
const transporter = nodemailer.createTransport({
  host: 'smtp.example.com', // Cambia por tu SMTP
  port: 587,
  secure: false,
  auth: {
    user: 'your_email@example.com',
    pass: 'your_email_password',
  },
});

app.post('/api/registerUser', async (req, res) => {
  const { email, nombre, apellido, role, telefono, password } = req.body;
  if (!email || !nombre || !role || !password) {
    return res.status(400).json({ error: 'Faltan datos obligatorios' });
  }

  const userId = uuidv4();
  pendingUsers.set(userId, { email, nombre, apellido, role, telefono, password });

  const baseUrl = process.env.BASE_URL || 'http://localhost:3000';
  const confirmUrl = `${baseUrl}/api/confirmUser?userId=${userId}&action=approve`;
  const rejectUrl = `${baseUrl}/api/confirmUser?userId=${userId}&action=reject`;

  const mailOptions = {
    from: '"Pets & Health" <no-reply@petsandhealth.com>',
    to: 'fernandezanderson562@gmail.com',
    subject: 'Solicitud de creación de usuario pendiente',
    html: `
      <p>Se ha registrado un nuevo usuario y está pendiente de aprobación:</p>
      <ul>
        <li><b>Nombre:</b> ${nombre} ${apellido || ''}</li>
        <li><b>Email:</b> ${email}</li>
        <li><b>Rol:</b> ${role}</li>
        <li><b>Teléfono:</b> ${telefono || 'No proporcionado'}</li>
      </ul>
      <p>Para aprobar al usuario, haz clic <a href="${confirmUrl}">aquí</a>.</p>
      <p>Para rechazar al usuario, haz clic <a href="${rejectUrl}">aquí</a>.</p>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return res.status(200).json({ message: 'Usuario pendiente creado y email enviado' });
  } catch (error) {
    console.error('Error enviando email:', error);
    return res.status(500).json({ error: 'Error enviando email' });
  }
});

app.get('/api/confirmUser', async (req, res) => {
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
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Backend Pets & Health escuchando en puerto ${port}`);
});
