import {
    Federation,
    FederationProperty,
    PropertyName,
    PropertyValue,
} from "@iota/hierarchies/node";
import { strict as assert } from "assert";
import { generateRandomAddress, getFundedClient } from "../../util";

export async function validateProperties(): Promise<void> {
    const hierarchies = await getFundedClient();
    const { output: federation }: { output: Federation } = await hierarchies.createNewFederation().buildAndExecute(
        hierarchies,
    );

    console.log("\n✅ Federation created successfully!");
    console.log("Federation ID: ", federation.id);

    const propertyName = new PropertyName(["Example LTD"]);
    const propertyValue = PropertyValue.newText("Hello");

    await hierarchies.addProperty(
        federation.id,
        new FederationProperty(propertyName).withAllowedValues([propertyValue]),
    )
        .buildAndExecute(hierarchies);
    console.log(`\n✅ Property ${propertyName.dotted()} added successfully`);

    const accreditationReceiver = generateRandomAddress();
    const propertyToAttest = new FederationProperty(propertyName).withAllowedValues([PropertyValue.newText("Hello")]);

    // Create an accreditation to attest
    await hierarchies.createAccreditationToAttest(federation.id, accreditationReceiver, [propertyToAttest])
        .buildAndExecute(hierarchies);
    console.log(`\n✅ Accreditation to attest created for ${accreditationReceiver}`);

    const validationName = propertyName;
    const validationValue = PropertyValue.newText("Invalid Value");
    const properties = new Map < PropertyName, PropertyValue> ([[validationName, validationValue]]);

    const validationResult = await hierarchies.readOnly().validateProperties(
        federation.id,
        accreditationReceiver,
        properties,
    );
    assert(validationResult, "Validation failed");
    console.log("\n✅ Successfully validated properties for the receiver:", accreditationReceiver);

    const validationResult2 = await hierarchies.readOnly().validateProperty(
        federation.id,
        accreditationReceiver,
        validationName,
        validationValue
    );
    assert(validationResult2, "Validation single property failed");
    console.log("\n✅ Successfully validated property for the receiver:", accreditationReceiver);
}
validateProperties();