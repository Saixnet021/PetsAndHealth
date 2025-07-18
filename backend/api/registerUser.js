import nodemailer from 'nodemailer';
import { v4 as uuidv4 } from 'uuid';

let pendingUsers = new Map(); // userId -> userData

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

export default async function handler(req, res) {
  if (req.method === 'POST') {
    const { email, nombre, apellido, role, telefono, password } = req.body;
    if (!email || !nombre || !role || !password) {
      return res.status(400).json({ error: 'Faltan datos obligatorios' });
    }

    const userId = uuidv4();
    pendingUsers.set(userId, { email, nombre, apellido, role, telefono, password });

    const confirmUrl = `${process.env.BASE_URL}/api/confirmUser?userId=${userId}&action=approve`;
    const rejectUrl = `${process.env.BASE_URL}/api/confirmUser?userId=${userId}&action=reject`;

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
  } else {
    res.setHeader('Allow', ['POST']);
    res.status(405).end(`Método ${req.method} no permitido`);
  }
}
