___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "displayName": "Elevar Monitoring Variable",
  "description": "Add tracking and validation to your variable values, make sure no errors go unnoticed \u0026 fix critical errors immediately.\n\nThe variables work in combination with The Elevar Monitoring Core Tag.",
  "categories": ["UTILITY", "ANALYTICS", "TAG_MANAGEMENT"],
  "securityGroups": [],
  "id": "cvt_temp_public_id",
  "type": "MACRO",
  "version": 1,
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "variableName",
    "displayName": "Variable Name",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "This should equal the GTM Variable Name. This is used to report what tags were associated to the error to the Elevar Monitoring dashboard."
  },
  {
    "type": "TEXT",
    "name": "dataLayerKey",
    "displayName": "Data Layer Key",
    "simpleValueType": true,
    "help": "Fill in the dataLayer key using just the name of the key itself. If you have nested keys, ie. { meta : { country : \u0027nl\u0027, language : \u0027en\u0027} then use dot notation, ie. meta.country or meta.language. \u003cstrong\u003eNOTE:\u003c/strong\u003e Make sure that every key used is also included in the Permissions.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "valueHint": "ecommerce.purchase.products"
  },
  {
    "type": "RADIO",
    "name": "required",
    "displayName": "Required",
    "radioItems": [
      {
        "value": true,
        "displayValue": "True"
      },
      {
        "value": false,
        "displayValue": "False"
      }
    ],
    "simpleValueType": true,
    "help": "Should the variable always contain a value when it is used or can it also be undefined?"
  },
  {
    "type": "RADIO",
    "name": "valueType",
    "displayName": "Value type",
    "radioItems": [
      {
        "value": "value",
        "displayValue": "Value",
        "subParams": []
      },
      {
        "value": "array",
        "displayValue": "Array"
      },
      {
        "value": "object",
        "displayValue": "Object"
      }
    ],
    "simpleValueType": true,
    "help": "What type of value should the data layer key contain. This is used to validate the input in a different way. \u003cstrong\u003eValue:\u003c/strong\u003e The value must match all of the conditions. \u003cstrong\u003eArray: \u003c/strong\u003e\nEach item in the array must match the each condition. \u003cstrong\u003eObject: \u003c/strong\u003e Validation is performed against object keys."
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "validationTable",
    "displayName": "New Condition",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Key (optional)",
        "name": "key",
        "type": "TEXT",
        "valueValidators": []
      },
      {
        "defaultValue": "",
        "displayName": "Condition",
        "name": "condition",
        "type": "SELECT",
        "selectItems": [
          {
            "value": "equals",
            "displayValue": "Equals"
          },
          {
            "value": "contains",
            "displayValue": "Contains"
          },
          {
            "value": "startsWith",
            "displayValue": "Starts with"
          },
          {
            "value": "endsWith",
            "displayValue": "Ends with"
          },
          {
            "value": "notEqual",
            "displayValue": "Does not equal"
          },
          {
            "value": "notContain",
            "displayValue": "Does not contain"
          },
          {
            "value": "notStartWith",
            "displayValue": "Does not start with"
          },
          {
            "value": "notEndWith",
            "displayValue": "Does not end with"
          },
          {
            "value": "lengthOf",
            "displayValue": "Has length of"
          },
          {
            "value": "isType",
            "displayValue": "Is of type"
          },
          {
            "value": "notType",
            "displayValue": "Is not of type"
          }
        ]
      },
      {
        "defaultValue": "",
        "displayName": "Condition value",
        "name": "conditionValue",
        "type": "TEXT"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "debugMode",
    "simpleValueType": true,
    "defaultValue": "{{Debug Mode}}",
    "displayName": "Debug Mode Variable",
    "help": "The Debug Mode Variable is used to capture errors only when not in Preview Mode. In Preview Mode variables behave differently and they are calculated even when tags don\u0027t use them."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Required Modules
const log = require("logToConsole");
const getType = require("getType");
const copyFromDataLayer = require("copyFromDataLayer");
const createQueue = require("createQueue");

const addValidationError = createQueue("elevar_gtm_errors");

// Object path traversal function
const deepValue = (obj, path) => path.split(".").reduce((a, v) => a[v], obj);

/**
 * Function to add new error to validation_errors
 *
 * @params
 * message - error message
 * error_id - id that can be used to identify errors
 */
const addError = (eventId, dataLayerKey, variableName) => (
  value,
  condition,
  expected
) => {
  log("GTM Error: ", {
    eventId: eventId,
    dataLayerKey: dataLayerKey,
    variableName: variableName,
    error: {
      value: value,
      condition: condition,
      conditionValue: expected
    }
  });

  addValidationError({
    eventId: eventId,
    dataLayerKey: dataLayerKey,
    variableName: variableName,
    error: {
      message: dataLayerKey + "=" + value + " " + condition + " " + expected,
      value: value,
      condition: condition,
      conditionValue: expected
    }
  });
};

const newError = addError(
  data.gtmEventId,
  data.dataLayerKey,
  data.variableName
);

const isValid = (value, condition, expectedValue) => {
  switch (condition) {
    case "equals":
      if (value !== expectedValue) {
        return false;
      }
      return true;

    case "contains":
      if (getType(value) !== "string") value = value.toString();
      if (value.indexOf(expectedValue) === -1) {
        return false;
      }
      return true;

    case "startsWith":
      if (getType(value) !== "string") value = value.toString();
      if (value.indexOf(expectedValue) !== 0) {
        return false;
      }
      return true;

    case "endsWith":
      if (getType(value) !== "string") value = value.toString();
      if (
        value.lastIndexOf(expectedValue) + expectedValue.length !==
        value.length
      ) {
        return false;
      }
      return true;

    case "notEqual":
      if (expectedValue === "undefined") {
        if (value === undefined) {
          return false;
        }
      } else if (value === expectedValue) {
        return false;
      }
      return true;

    case "notContain":
      if (getType(value) !== "string") value = value.toString();
      if (value.indexOf(expectedValue) > -1) {
        return false;
      }
      return true;

    case "notStartWith":
      if (getType(value) !== "string") value = value.toString();
      if (value.indexOf(expectedValue) === 0) {
        return false;
      }
      return true;

    case "notEndWith":
      if (getType(value) !== "string") value = value.toString();
      if (
        value.lastIndexOf(expectedValue) + expectedValue.length ===
        value.length
      ) {
        return false;
      }
      return true;

    case "hasLengthOf":
      if (getType(value) !== "string") value = value.toString();
      if (value.length !== expectedValue) {
        return false;
      }
      return true;

    case "isType":
      if (getType(value) !== expectedValue) {
        return false;
      }
      return true;

    case "notType":
      if (getType(value) === expectedValue) {
        return false;
      }
      return true;

    default:
      return true;
  }
};

// value type === value
// whole table is about one value (ignore keys)
const validateValue = (value, table) => {
  if (["array", "object"].some(item => item === getType(value))) {
    newError(value, "is single value", "string or number");
  } else {
    for (let i = 0; i < table.length; i++) {
      if (!isValid(value, table[i].condition, table[i].conditionValue)) {
        newError(value, table[i].condition, table[i].conditionValue);
      }
    }
  }
};

// value type === object
// for each row in table look for key and validate
const validateObject = (item, table) => {
  for (let i = 0; i < table.length; i++) {
    if (
      !isValid(item[table[i].key], table[i].condition, table[i].conditionValue)
    ) {
      newError(item[table[i].key], table[i].condition, table[i].conditionValue);
    }
  }
};

// value type === array
// for each item in array run validation
const validateArray = (arr, table) => {
  for (let i = 0; i < arr.length; i++) {
    if (typeof arr[i] === "object") {
      validateObject(arr[i], table);
    } else {
      validateValue(arr[i], table);
    }
  }
};

// Custom dataLayer get function to fix permission error
const getDataLayerValue = (copyFromDataLayerFunc, key) => {
  if (key.indexOf(".0") !== -1) {
    const split = key.split(".0");
    const initialValue = copyFromDataLayerFunc(split[0]);
    if (!initialValue) return initialValue;

    return split.slice(1).reduce((a, v) => {
      if (getType(a) !== "array") return undefined;
      if (!v) return a[0];

      return deepValue(a[0], v.slice(1));
    }, initialValue);
  }
  return copyFromDataLayerFunc(key);
};

const validationTable = data.validationTable;
const valueType = data.valueType;
const debugMode = data.debugMode;
const dataLayerValue = getDataLayerValue(copyFromDataLayer, data.dataLayerKey);

// Don't validate if item is undefined
// But add error if item is required
if (!debugMode) {
  if (typeof dataLayerValue === "undefined") {
    if (data.required === true) {
      newError(dataLayerValue, "required", "true");
    }
  } else {
    switch (valueType) {
      case "value":
        // Exit early if there are no table values.
        if (!validationTable) break;
        validateValue(dataLayerValue, validationTable);
        break;

      case "object":
        if (getType(dataLayerValue) !== "object") {
          newError(dataLayerValue, "typeOf", "object");
        }
        // Exit early if there are no table values.
        if (!validationTable) break;
        validateObject(dataLayerValue, validationTable);
        break;

      case "array":
        if (getType(dataLayerValue) !== "array") {
          newError(dataLayerValue, "typeOf", "array");
        }
        // Exit early if there are no table values.
        if (!validationTable) break;
        validateArray(dataLayerValue, validationTable);
        break;

      default:
        break;
    }
  }
}

return dataLayerValue;


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "ecommerce.*"
              },
              {
                "type": 1,
                "string": "VariantPrice"
              },
              {
                "type": 1,
                "string": "VisitorType"
              },
              {
                "type": 1,
                "string": "orderEmail"
              },
              {
                "type": 1,
                "string": "CustomerPhone"
              },
              {
                "type": 1,
                "string": "CustomerLastName"
              },
              {
                "type": 1,
                "string": "CustomerFirstName"
              },
              {
                "type": 1,
                "string": "SearchTerms"
              },
              {
                "type": 1,
                "string": "CustomerEmail"
              },
              {
                "type": 1,
                "string": "visitorId"
              },
              {
                "type": 1,
                "string": "visitorType"
              },
              {
                "type": 1,
                "string": "CustomerId"
              },
              {
                "type": 1,
                "string": "CustomerOrdersCount"
              },
              {
                "type": 1,
                "string": "CustomerTotalSpent"
              },
              {
                "type": 1,
                "string": "pageType"
              },
              {
                "type": 1,
                "string": "cartTotal"
              },
              {
                "type": 1,
                "string": "shopifyProductId"
              },
              {
                "type": 1,
                "string": "VariantCompareAtPrice"
              },
              {
                "type": 1,
                "string": "cartItems"
              },
              {
                "type": 1,
                "string": "event"
              },
              {
                "type": 1,
                "string": "discountTotalAmount"
              },
              {
                "type": 1,
                "string": "discountTotalSavings"
              },
              {
                "type": 1,
                "string": "CustomerCity"
              },
              {
                "type": 1,
                "string": "CustomerZip"
              },
              {
                "type": 1,
                "string": "CustomerAddress1"
              },
              {
                "type": 1,
                "string": "CustomerAddress2"
              },
              {
                "type": 1,
                "string": "CustomerCountryCode"
              },
              {
                "type": 1,
                "string": "CustomerProvince"
              },
              {
                "type": 1,
                "string": "CustomerOrdersCount"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  },
                  {
                    "type": 1,
                    "string": "execute"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "elevar_gtm_errors"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": false
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Validation / Value / Undefined
  code: |-
    mockData.dataLayerKey = "ecommerce.impressions.0.not_real_value";
    let variableResult = runCode(mockData);

    // Verify that the variable returns the value.
    assertThat(variableResult).isEqualTo(undefined);

    // Verify that there is an error because the value is required.
    assertThat(window.elevar_gtm_errors).hasLength(1);
- name: Validation / Value / Number - VALID
  code: |-
    mockData.validationTable = [
      { key: "", condition: "equals", conditionValue: 100 },
      { key: "", condition: "contains", conditionValue: "1" },
      { key: "", condition: "startsWith", conditionValue: "1" },
      { key: "", condition: "endsWith", conditionValue: "00" },
      { key: "", condition: "notEqual", conditionValue: 10 },
      { key: "", condition: "notContain", conditionValue: "false" },
      { key: "", condition: "notStartWith", conditionValue: "00" },
      { key: "", condition: "notEndWith", conditionValue: "10" },
      { key: "", condition: "hasLengthOf", conditionValue: 3 },
      { key: "", condition: "isType", conditionValue: "number" },
      { key: "", condition: "notType", conditionValue: "string" },
    ];

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns the correct value.
    assertThat(variableResult).isEqualTo(100);

    // No errors
    assertThat(window.elevar_gtm_errors).hasLength(0);
- name: Validation / Value / Number - INVALID
  code: |-
    mockData.validationTable = [
      { key: "", condition: "equals", conditionValue: 1000 },
      { key: "", condition: "contains", conditionValue: "2" },
      { key: "", condition: "startsWith", conditionValue: "00" },
      { key: "", condition: "endsWith", conditionValue: "10" },
      { key: "", condition: "notEqual", conditionValue: 100 },
      { key: "", condition: "notContain", conditionValue: "100" },
      { key: "", condition: "notStartWith", conditionValue: "10" },
      { key: "", condition: "notEndWith", conditionValue: "00" },
      { key: "", condition: "hasLengthOf", conditionValue: 2 },
      { key: "", condition: "isType", conditionValue: "string" },
      { key: "", condition: "notType", conditionValue: "number" },
    ];

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns the value.
    assertThat(variableResult).isEqualTo(100);

    // Verify that there is an error for each failure
    assertThat(window.elevar_gtm_errors).hasLength(mockData.validationTable.length);
- name: Validation / Value / String - VALID
  code: |-
    mockData.dataLayerKey = "ecommerce.impressions.0.name";
    mockData.validationTable = [
      { key: "", condition: "equals", conditionValue: "14 Day Challenge - Starts March 9th" },
      { key: "", condition: "contains", conditionValue: "Day Challenge -" },
      { key: "", condition: "startsWith", conditionValue: "14 Day" },
      { key: "", condition: "endsWith", conditionValue: "March 9th" },
      { key: "", condition: "notEqual", conditionValue: "14 Day Challenge - Starts June 9th" },
      { key: "", condition: "notContain", conditionValue: "Begins" },
      { key: "", condition: "notStartWith", conditionValue: "15" },
      { key: "", condition: "notEndWith", conditionValue: "10th" },
      { key: "", condition: "hasLengthOf", conditionValue: 35 },
      { key: "", condition: "isType", conditionValue: "string" },
      { key: "", condition: "notType", conditionValue: "number" },
    ];

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns the correct value.
    assertThat(variableResult).isEqualTo("14 Day Challenge - Starts March 9th");

    // No errors
    assertThat(window.elevar_gtm_errors).hasLength(0);
- name: Validation / Value / String - INVALID
  code: |-
    mockData.dataLayerKey = "ecommerce.impressions.0.name";
    mockData.validationTable = [
      { key: "", condition: "equals", conditionValue: "15 Day Challenge - Starts March 9th" },
      { key: "", condition: "contains", conditionValue: "Days Challenge -" },
      { key: "", condition: "startsWith", conditionValue: "14 Days" },
      { key: "", condition: "endsWith", conditionValue: "March 9t" },
      { key: "", condition: "notEqual", conditionValue: "14 Day Challenge - Starts March 9th" },
      { key: "", condition: "notContain", conditionValue: "Challenge" },
      { key: "", condition: "notStartWith", conditionValue: "14" },
      { key: "", condition: "notEndWith", conditionValue: "9th" },
      { key: "", condition: "hasLengthOf", conditionValue: 34 },
      { key: "", condition: "isType", conditionValue: "boolean" },
      { key: "", condition: "notType", conditionValue: "string" },
    ];

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns the correct value.
    assertThat(variableResult).isEqualTo("14 Day Challenge - Starts March 9th");

    // No errors
    assertThat(window.elevar_gtm_errors).hasLength(mockData.validationTable.length);
- name: Validation / Value / Boolean - VALID
  code: |-
    mockData.dataLayerKey = "ecommerce.impressions.0.isCool";
    mockData.validationTable = [
      { key: "", condition: "equals", conditionValue: true },
      { key: "", condition: "contains", conditionValue: "true" },
      { key: "", condition: "startsWith", conditionValue: "tru" },
      { key: "", condition: "endsWith", conditionValue: "ue" },
      { key: "", condition: "notEqual", conditionValue: false },
      { key: "", condition: "notContain", conditionValue: "something" },
      { key: "", condition: "notStartWith", conditionValue: "fal" },
      { key: "", condition: "notEndWith", conditionValue: "lse" },
      { key: "", condition: "hasLengthOf", conditionValue: 4 },
      { key: "", condition: "isType", conditionValue: "boolean" },
      { key: "", condition: "notType", conditionValue: "number" },
    ];

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns the correct value.
    assertThat(variableResult).isEqualTo(true);

    // No errors
    assertThat(window.elevar_gtm_errors).hasLength(0);
- name: Validation / Value / Boolean - INVALID
  code: |-
    mockData.dataLayerKey = "ecommerce.impressions.0.isCool";
    mockData.validationTable = [
      { key: "", condition: "equals", conditionValue: false },
      { key: "", condition: "contains", conditionValue: "false" },
      { key: "", condition: "startsWith", conditionValue: "fals" },
      { key: "", condition: "endsWith", conditionValue: "alse" },
      { key: "", condition: "notEqual", conditionValue: true },
      { key: "", condition: "notContain", conditionValue: "true" },
      { key: "", condition: "notStartWith", conditionValue: "true" },
      { key: "", condition: "notEndWith", conditionValue: "true" },
      { key: "", condition: "hasLengthOf", conditionValue: 5 },
      { key: "", condition: "isType", conditionValue: "string" },
      { key: "", condition: "notType", conditionValue: "boolean" },
    ];

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns the correct value.
    assertThat(variableResult).isEqualTo(true);

    // No errors
    assertThat(window.elevar_gtm_errors).hasLength(mockData.validationTable.length);
- name: Validation / Value / Index of Array
  code: |-
    mockData = {
      variableName: "Variable Name",
      valueType: "value",
      debugMode: false,
      dataLayerKey: "ecommerce.productNames.0",
      required: true,
      gtmEventId: 0
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isNotEqualTo(false);
    assertThat(variableResult).isEqualTo(dataLayer.ecommerce.productNames[0]);
- name: Validation / Value / No validation conditions
  code: |-
    mockData = {
      variableName: "Variable Name",
      valueType: "value",
      debugMode: false,
      dataLayerKey: "ecommerce.impressions.0.price",
      required: true,
      gtmEventId: 0
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isEqualTo(100);
- name: Validation / Array of Strings - VALID
  code: |-
    mockData.valueType = "array";
    mockData.dataLayerKey = "ecommerce.productNames";
    mockData.validationTable = [
      { key: "", condition: "contains", conditionValue: "name" },
      { key: "", condition: "startsWith", conditionValue: "name" },
      { key: "", condition: "notEqual", conditionValue: false },
      { key: "", condition: "notContain", conditionValue: "something" },
      { key: "", condition: "notStartWith", conditionValue: "names" },
      { key: "", condition: "notEndWith", conditionValue: "name" },
      { key: "", condition: "hasLengthOf", conditionValue: 5 },
      { key: "", condition: "isType", conditionValue: "string" },
      { key: "", condition: "notType", conditionValue: "number" },
    ];

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns the correct value.
    assertThat(variableResult).isEqualTo(dataLayer.ecommerce.productNames);

    // No errors
    assertThat(window.elevar_gtm_errors).hasLength(0);
- name: Validation / Array of Strings - INVALID
  code: |-
    mockData.valueType = "array";
    mockData.dataLayerKey = "ecommerce.productNames";
    mockData.validationTable = [
      { key: "", condition: "isType", conditionValue: "number" },
    ];

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns the correct value.
    assertThat(variableResult).isEqualTo(dataLayer.ecommerce.productNames);

    // No errors
    assertThat(window.elevar_gtm_errors).hasLength(mockData.validationTable.length * dataLayer.ecommerce.productNames.length);
- name: Validation / Array of Objects - VALID
  code: |
    mockData = {
      variableName: "Variable Name",
      valueType: "array",
      debugMode: false,
      validationTable: [
        { key: "name", condition: "notEqual", conditionValue: "tommy"},
        { key: "type", condition: "equals", conditionValue: "person"},
      ],
      dataLayerKey: "ecommerce.objectList",
      required: true,
      gtmEventId: 0
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isEqualTo(dataLayer.ecommerce.objectList);
    assertThat(window.elevar_gtm_errors).hasLength(0);
- name: Validation / Array of Objects - INVALID
  code: |
    mockData = {
      variableName: "Variable Name",
      valueType: "array",
      debugMode: false,
      validationTable: [
        { key: "name", condition: "notEqual", conditionValue: "tommy"},
        { key: "name", condition: "equals", conditionValue: "bob" },
        { key: "type", condition: "equals", conditionValue: "person"},
      ],
      dataLayerKey: "ecommerce.objectList",
      required: true,
      gtmEventId: 0
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isEqualTo(dataLayer.ecommerce.objectList);
    assertThat(window.elevar_gtm_errors).hasLength(1);
    assertThat(window.elevar_gtm_errors[0].error.value).isEqualTo("reese");
    assertThat(window.elevar_gtm_errors[0].error.condition).isEqualTo("equals");
    assertThat(window.elevar_gtm_errors[0].error.conditionValue).isEqualTo("bob");
- name: Validation / Array / No validation conditions
  code: |-
    mockData = {
      variableName: "Variable Name",
      valueType: "array",
      debugMode: false,
      dataLayerKey: "ecommerce.productNames",
      required: true,
      gtmEventId: 0
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isEqualTo(dataLayer.ecommerce.productNames);
- name: Validation / Object / No validation conditions
  code: |-
    mockData = {
      variableName: "Variable Name",
      valueType: "object",
      debugMode: false,
      dataLayerKey: "ecommerce.actionField",
      required: true,
      gtmEventId: 0
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isNotEqualTo(false);
    assertThat(variableResult).isEqualTo(dataLayer.ecommerce.actionField);
- name: Validation / Object / With validation conditions - VALID
  code: |
    mockData = {
      variableName: "Variable Name",
      valueType: "object",
      debugMode: false,
      validationTable: [
        { key: "name", condition: "notEqual", conditionValue: "tommy"},
        { key: "name", condition: "equals", conditionValue: "bob"},
        { key: "type", condition: "equals", conditionValue: "person"},
      ],
      dataLayerKey: "ecommerce.objectList.0",
      required: true,
      gtmEventId: 0
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isEqualTo({ name: 'bob', type: 'person' });
    assertThat(window.elevar_gtm_errors).hasLength(0);
- name: Validation / Object / With validation conditions - INVALID
  code: |
    mockData = {
      variableName: "Variable Name",
      valueType: "object",
      debugMode: false,
      validationTable: [
        { key: "name", condition: "notEqual", conditionValue: "tommy"},
        { key: "name", condition: "equals", conditionValue: "reese"},
        { key: "type", condition: "equals", conditionValue: "person"},
      ],
      dataLayerKey: "ecommerce.objectList.0",
      required: true,
      gtmEventId: 0
    };

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isNotEqualTo(undefined);
    assertThat(variableResult).isEqualTo({ name: 'bob', type: 'person' });
    assertThat(window.elevar_gtm_errors).hasLength(1);
setup: "const log = require('logToConsole');\n\n/* MockData provided by input fields\
  \ */\nlet mockData = {\n  variableName: \"Variable Name\",\n  valueType: \"value\"\
  ,\n  validationTable: [{ key: \"\", condition: \"isType\", conditionValue: \"number\"\
  \ }],\n  debugMode: false,\n  dataLayerKey: \"ecommerce.impressions.0.price\",\n\
  \  required: true,\n  gtmEventId: 0\n};\n\nlet window = {};\nlet dataLayer = {\n\
  \  ecommerce: {\n    currencyCode: \"USD\",\n    actionField: {\n      list: \"\
  Shopping Cart\",\n      search: \"hello\"\n    },\n    objectList: [{name: 'bob',\
  \ type: 'person'}, {name: 'reese', type: 'person'}],\n    productNames: ['name1',\
  \ 'name2', 'name3'],\n    impressions: [\n      {\n        position: 0,\n      \
  \  id: \"\",\n        productId: 4518425362468,\n        variantId: 31697496047652,\n\
  \        shopifyId: \"shopify_US_4518425362468_31697496047652\",\n        name:\
  \ \"14 Day Challenge - Starts March 9th\",\n        isCool: true,\n        quantity:\
  \ 1,\n        price: 100,\n        brand: \"Elevar Gear - This is a Test Store\"\
  ,\n        variant: null\n      },\n    ]\n  }\n};\n\nmock('copyFromDataLayer',\
  \ (variableName) => {\n  switch(variableName) {\n    case \"ecommerce\":\n     \
  \ return dataLayer.ecommerce;\n    case \"ecommerce.currencyCode\":\n      return\
  \ dataLayer.ecommerce.currencyCode;\n    case \"ecommerce.impressions\":\n     \
  \ return dataLayer.ecommerce.impressions;\n    case \"ecommerce.objectList\":\n\
  \      return dataLayer.ecommerce.objectList;\n    case \"ecommerce.productNames\"\
  :\n      return dataLayer.ecommerce.productNames;\n    case \"ecommerce.actionField\"\
  :\n      return dataLayer.ecommerce.actionField;\n    default:\n      return undefined;\n\
  \  }\n});\n\n/*\nCreates an array in the window with the key provided and\nreturns\
  \ a function that pushes items to that array.\n*/\nmock('createQueue', (key) =>\
  \ {\n  const pushToArray = (arr) => (item) => {\n    arr.push(item);\n  };\n  \n\
  \  if (!window[key]) window[key] = [];\n  return pushToArray(window[key]);\n});\n"


___NOTES___

Created on 9/13/2019, 3:02:56 PM


