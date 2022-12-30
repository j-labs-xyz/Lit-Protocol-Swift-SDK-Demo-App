# Lit-Protocol-Swift-SDK-Demo-App

## 1. Set up local workspace

### 1.1. Set up Lit Protocol projects

#### 1.1.1. set up Lit Protocol Relay Server

* check out https://github.com/j-labs-xyz/relay-server/, switch to `dev` branch

* create `.env` file
```
REDIS_URL=redis://localhost:6379
HOST=0.0.0.0
PORT=3001
ENABLE_HTTPS=true
LIT_TXSENDER_RPC_URL=https://rpc.ankr.com/polygon_mumbai
LIT_TXSENDER_PRIVATE_KEY=484c1904d15cd4282285e6581fefc569984d5e2da10c3147d03398ebcdbe301c
GOOGLE_CLIENT_ID=587679218229-hp7sfg1o5o63f8c5h14nldb0mj830ohi.apps.googleusercontent.com
``` 

* run `redis-server`

* run `yarn start` to start the relay server at https://localhost:3001

#### 1.1.2. set up Lit Protocol Google Authentication Example Project

* check out https://github.com/j-labs-xyz/oauth-pkp-signup-example, switch to `dev` branch

* create `.env` file
```
GENERATE_SOURCEMAP=false
```

* run `yarn start` to start the app at http://localhost:3000

#### 1.1.3. set up Lit Protocol JS Serverless Function Test Project

* check out https://github.com/j-labs-xyz/js-serverless-function-test, switch to `feature/jlabs` branch

* run `yarn run sign`, the test should run and pass

### 1.2. How things work together?

#### 1.2.1. Gooel authentication and mint PKP

* Open `http://localhost:3000/` in browser, and open developer console

* Click on Google SignIn component to log in to your Google account

* Expect the message to be `Successfully authed and minted PKP!`

* Expect to see `Successfully authed` in the console, and copy the object (it has public key and address) for later use

#### 1.2.2. Use authentication result to get session signature from Lit

* Click on `Encrypt with Lit` button

* Expect to see `got session sig from node and PKP` in the console, and copy the object (it has session signature)

#### 1.2.3. Use the objects copied from 1.2.1. and 1.2.2. in the test

* Go to project `js-serverless-function-test`

* Open `signTxnTest.js`, replace `pkp`  with the object from 1.2.1.

* Open `js-sdkTests/signTxn.js`, replace `authSig` with the object from 1.2.2.

* Before running `yarn run sign`, you need to send some MATIC to the minted PKP's address in order for it to transact

* Now your minted PKP from Google authentication should be able to sign and broadcast transactions