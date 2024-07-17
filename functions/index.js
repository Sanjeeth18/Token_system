const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

exports.resetVegNonvegFields = functions.pubsub.schedule("every 24 hours")
  .onRun(async (context) => {
    const batch = db.batch();

    const tokenCollectRef = db.collection("Tokens").doc("Counts");

    // Update the fields to 0
    batch.update(tokenCollectRef, { veg: 0, nonveg: 0 });

    await batch.commit();

    console.log("Veg and Nonveg fields have been reset to 0.");
    return null;
  });
