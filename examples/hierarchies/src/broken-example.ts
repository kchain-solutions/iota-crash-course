import {
    Federation,
    FederationProperty,
    PropertyName,
    PropertyValue,
} from "@iota/hierarchies/node";
import { strict as assert } from "assert";
import { generateRandomAddress, getFundedClient } from "./utils";

// Test constants
const VALID_VALUE = "Valid Value";
const INVALID_VALUE = "Invalid Value";
const PROPERTY_NAME = new PropertyName(["Example LTD"]);
const ACCREDITATION_RECEIVER = generateRandomAddress();

export async function validateProperties(): Promise<void> {
    const hierarchies = await getFundedClient();
    const { output: federation }: { output: Federation } = await hierarchies.createNewFederation().buildAndExecute(
        hierarchies,
    );

    console.log("\n✅ Federation created successfully!");
    console.log("Federation ID: ", federation.id);

    const propertyValue = PropertyValue.newText(VALID_VALUE);

    await hierarchies.addProperty(
        federation.id,
        new FederationProperty(PROPERTY_NAME).withAllowedValues([propertyValue]),
    )
        .buildAndExecute(hierarchies);
    console.log(`\n✅ Property ${PROPERTY_NAME.dotted()} added successfully with allowed value: "${VALID_VALUE}"`);

    const propertyToAttest = new FederationProperty(PROPERTY_NAME).withAllowedValues([PropertyValue.newText(VALID_VALUE)]);

    // Create an accreditation to attest
    await hierarchies.createAccreditationToAttest(federation.id, ACCREDITATION_RECEIVER, [propertyToAttest])
        .buildAndExecute(hierarchies);
    console.log(`\n✅ Accreditation to attest created for ${ACCREDITATION_RECEIVER}`);
    console.log(`   Allowed value in attestation: "${VALID_VALUE}"`);

    // Test 1: Validate with the CORRECT value (should PASS)
    console.log(`\n🔍 Test 1: Validating with CORRECT value "${VALID_VALUE}"...`);
    const validValue = PropertyValue.newText(VALID_VALUE);
    const validProperties = new Map<PropertyName, PropertyValue>([[PROPERTY_NAME, validValue]]);

    const validationResult = await hierarchies.readOnly().validateProperties(
        federation.id,
        ACCREDITATION_RECEIVER,
        validProperties,
    );
    assert(validationResult, `Test 1 FAILED: Validation should PASS for "${VALID_VALUE}"`);
    console.log(`✅ Test 1 PASSED: validateProperties correctly validated "${VALID_VALUE}"`);

    const validationResult2 = await hierarchies.readOnly().validateProperty(
        federation.id,
        ACCREDITATION_RECEIVER,
        PROPERTY_NAME,
        validValue
    );
    assert(validationResult2, `Test 1 FAILED: Single property validation should PASS for "${VALID_VALUE}"`);
    console.log(`✅ Test 1 PASSED: validateProperty correctly validated "${VALID_VALUE}"`);

    // Test 2: Validate with an INCORRECT value (should FAIL)
    console.log(`\n🔍 Test 2: Validating with INCORRECT value "${INVALID_VALUE}"...`);
    const invalidValue = PropertyValue.newText(INVALID_VALUE);
    const invalidProperties = new Map<PropertyName, PropertyValue>([[PROPERTY_NAME, invalidValue]]);

    // Error HERE: validateProperties returns true even for invalid value
    const invalidResult = await hierarchies.readOnly().validateProperties(
        federation.id,
        ACCREDITATION_RECEIVER,
        invalidProperties,
    );
    assert(!invalidResult, `Test 2 FAILED: Validation should FAIL for "${INVALID_VALUE}"`);
    console.log(`✅ Test 2 PASSED: validateProperties correctly rejected "${INVALID_VALUE}"`);

    //Error HERE: validateProperty returns true even for invalid value
    const invalidResult2 = await hierarchies.readOnly().validateProperty(
        federation.id,
        ACCREDITATION_RECEIVER,
        PROPERTY_NAME,
        invalidValue
    );
    assert(!invalidResult2, `Test 2 FAILED: Single property validation should FAIL for "${INVALID_VALUE}"`);
    console.log(`✅ Test 2 PASSED: validateProperty correctly rejected "${INVALID_VALUE}"`);

    console.log("\n🎉 All tests passed! Both validation methods work correctly.");
}

validateProperties().catch(err => {
    console.error("\n❌ Error:", err.message);
    process.exit(1);
});