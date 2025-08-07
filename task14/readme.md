📄 Task #14: Unleash Feature Flag Documentation
***************************************************

📌 What is Unleash? (Simplified Explanation)
 • Unleash is a feature flag management tool.
 • It allows you to control specific features in your app — you can enable or disable them without changing or redeploying your code.

🧠 Example:
---------------
    Let’s say you added a new update to your app. Using Unleash:
    • You enable it for testing.
    • If any error occurs, you can quickly disable it — no need to remove the code or redeploy.

✅ This helps with:
-----------------------    
     •  Safe rollout of features
      • Faster rollback during errors
       • Testing features with real users (A/B testing)
        • Scaling teams by separating release from deployment

🔧 What is Unleash Used For?
*******************************
   •  Unleash is a feature flag management tool that helps developers and teams:
   • Enable or disable features in real-time without changing the code or redeploying the application.
   • Safely test new features with a limited group of users before a full rollout.
   • Quickly roll back a feature if any bugs or issues are detected.
   • Gradually roll out updates (percentage-based rollout, user segments, etc.).
   • Experiment and A/B test features for better product decisions.

🧠 Real-world Use Case:
------------------------
   • Let’s say you’re releasing a new login flow. With Unleash:
   • You can enable it only for internal team members first.
   • If it works fine, you can slowly enable it for more users.
   • If an error occurs, you can immediately disable the feature — no redeployment needed.

⚙️ How to Set Up Unleash for a Local React Application
**************************************************************
  To install and start the unleah server  follow this .yml
  ```bash
  version: '3.8'
services:
  postgres:
    image: postgres:15
    container_name: unleash_postgres
    environment:
      POSTGRES_DB: unleash
      POSTGRES_USER: unleash_user
      POSTGRES_PASSWORD: password
    volumes:
      - unleash_pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  unleash:
    image: unleashorg/unleash-server
    container_name: unleash_server
    ports:
      - "4242:4242"
    environment:
      DATABASE_URL: postgres://unleash_user:password@postgres:5432/unleash
    depends_on:
      - postgres

volumes:
  unleash_pgdata:
```
🧩 1. Start the Unleash Server
   Create the file docker-compose.yml
   ```bash
   docker-compose up -d
   ```
Access Unleash dashboard:
****************************
http://localhost:4242
🔸 Make sure PostgreSQL is running locally and accessible with the above credentials
(Or use SQLite if you're testing: we can modify this for that).
🧩 2. Login to Unleash UI
     • Open: http://localhost:4242
     • Login with default credentials:
     • Username: admin
     • Password: unleash4all

🧩 3. Get the Client Key
    • In the UI, go to: API Access / Client Keys
   Copy the key: e.g.,
   ```bash
   default:development.1234567890
```
🧩 4. Now Setup React App
Inside your React app folder:
   Use npm or yarn:
   ```bash
   npm install unleash-client
            or
   yarn add unleash-client
``` 
✅ What the unleash-client Does in a React App
   • The unleash-client is an SDK that connects your React frontend to the Unleash server to:
   I)Fetch feature flags
   II)Evaluate them on the client-side
   III)Enable or disable UI features based on flag status

🔁 How It Works – Step by Step
  step 1.You install the SDK:
   ```bash
   npm install unleash-client
   ```
   ✅ Recommended Setup
📄 Step 2: Create a file
Create a file named something like:
    ```bash
    src/unleashClient.js
    ``` 
 step 3.You initialize the SDK in your app:
    ```bash
     import { initialize } from 'unleash-client';

     const unleash = initialize({
     url: 'http://localhost:4242/api/frontend', // URL to your Unleash server
     clientKey: 'default:development.1234567890', // You get this from the server
     appName: 'my-react-app',
     environment: 'development'
});
```
✅ Step 4: Use the Feature Flag in Your React Component
    • Why Use a Feature Flag in Step 4?
    • In Step 4, you're using a feature flag to conditionally enable or disable parts of your UI or     functionality, without changing your code or redeploying your app.

✅ Purpose of Feature Flags:
    • Control new features safely — turn features ON/OFF in real time.
    • Test in production — release to internal users before everyone.
    • Avoid breaking things — disable the feature instantly if there's an issue.
    • A/B Testing — show different features to different users.
Now that you’ve initialized Unleash in unleashClient.js, you need to:
  1.Start the SDK
  2.Wait for it to be ready
  3.Use flags in your components

  ```bash
  import { initialize } from 'unleash-client';

  const unleash = initialize({
  url: 'http://localhost:4242/api/frontend',
  clientKey: 'default:development.1234567890', // Replace with your actual key
  appName: 'my-react-app',
  environment: 'development'
});

export default unleash;
```
🧩 Create a wrapper to handle SDK readiness (optional but recommended)
  • Create a file src/hooks/useFeatureFlag.js:
  ```bash
  import { useEffect, useState } from 'react';
  import unleash from '../unleashClient';

export function useFeatureFlag(flagName) {
  const [enabled, setEnabled] = useState(false);

  useEffect(() => {
    const onReady = () => {
      const isEnabled = unleash.isEnabled(flagName);
      setEnabled(isEnabled);
    };

    unleash.on('ready', onReady);

    return () => {
      unleash.off('ready', onReady);
    };
  }, [flagName]);

  return enabled;
}
```
🛡️ Why We Use a Wrapper for Unleash in React
We create a custom wrapper around the Unleash SDK to cleanly integrate it into our React application. This wrapper helps us:

 • Initialize Unleash only once (centralized setup)
 • Easily access feature flags anywhere using a simple hook (e.g., useFeatureFlag('feature-name'))
 • Connect Unleash with React's state & lifecycle
 • Improve code reusability, readability, and performance
 • Avoid duplication and make flag management more scalable

This wrapper acts as a bridge between Unleash and React components, making feature flag control seamless and efficient across the app.

✅ Step 5: Use the Feature Flag in a React Component
```bash
import React from 'react';
import { useFeatureFlag } from './hooks/useFeatureFlag';

const MyComponent = () => {
  const newFeatureEnabled = useFeatureFlag('my-new-feature'); // your feature name

  return (
    <div>
      <h1>Welcome to My App!</h1>
      {newFeatureEnabled ? (
        <p>🎉 New Feature is Enabled!</p>
      ) : (
        <p>🚧 New Feature is Coming Soon!</p>
      )}
    </div>
  );
};

export default MyComponent;
```
Why Use a Feature Flag 
----------------------------
 • you're using a feature flag to conditionally enable or disable parts of your UI or functionality, without changing your code or redeploying your app.

✅ Purpose of Feature Flags:
 • Control new features safely — turn features ON/OFF in real time.
 • Test in production — release to internal users before everyone.
 • Avoid breaking things — disable the feature instantly if there's an issue.
 • A/B Testing — show different features to different users.

You're doing this:
```bash
const newFeatureEnabled = useFeatureFlag('my-new-feature');

{newFeatureEnabled ? (
  <p>🎉 New Feature is Enabled!</p>
) : (
  <p>🚧 New Feature is Coming Soon!</p>
)}
```
This means:
---------------
  * If the flag is enabled in Unleash dashboard, user sees the new feature.
  * If it's disabled, they see the old content or message.

🧠 Real-life example:
 • You're releasing a new payment system. You don't want to show it to everyone yet.
You create a feature flag:
```bash
const isNewPayment = useFeatureFlag('new-payment');
```
Now:
  * Keep new-payment flag OFF ➝ everyone sees old checkout.
  * Turn it ON for internal testers ➝ only they see new checkout.
  * Once confirmed, turn it ON for all users — no code change needed.

✅ Step 6: Create a Feature Toggle in Unleash Dashboard
   1.Go to http://localhost:4242
   2.Click on “Feature Toggles” > “Create a new feature toggle”
   3.Set Name as: my-new-feature
   4.Toggle it ON in the development environment
   5.Save and test it in your React app
🚀 You’re Done!
---------------------
* Now your React app is:
* Using Unleash to check feature flags
* Conditionally rendering based on flag values
* Fully ready for safe feature rollouts 🎯

