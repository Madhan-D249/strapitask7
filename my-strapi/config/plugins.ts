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

  // Enable Roles & Permissions plugin
  'users-permissions': {
    enabled: true,
  },

  // Enable Internationalization (i18n)
  i18n: {
    enabled: true,
  },

});
