export default () => ({
  // Enable Content-Type Builder
  'content-type-builder': {
    enabled: true,
  },

  // Enable Media Library
  upload: {
    enabled: true,
    config: {
      provider: 'local',
      providerOptions: {
        sizeLimit: 1000000, // 1MB limit per file (adjust as needed)
      },
    },
  },

  // Enable Email Plugin
  email: {
    config: {
      provider: 'nodemailer',
      providerOptions: {
        host: 'smtp.example.com', // replace with your SMTP host
        port: 587,
        auth: {
          user: 'madhandeva249@gmail.com',
          pass: 'Madhan1234',
        },
      },
      settings: {
        defaultFrom: 'madhandeva249@gmail.com',
        defaultReplyTo: 'madhandeva249@gmail.com',
      },
    },
  },

  // Enable Roles & Permissions plugin
  'users-permissions': {
    enabled: true,
  },

  // Enable Internationalization (i18n)
  i18n: {
    enabled: true,
  },

  // Enable Review Workflows (optional)
  'review-workflows': {
    enabled: true,
  },

  // Enable Webhooks (optional)
 // webhooks: {
   // enabled: true,
  //},

  // Enable Single Sign-On (SSO) (optional, only if installed)
  'single-sign-on': {
    enabled: true,
  },
});
