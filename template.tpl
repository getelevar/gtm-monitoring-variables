___INFO___

{
  "displayName": "Elevar - DataLayer Variable with Validation",
  "description": "Add core dataLayer values to check. Use the dropdown to select a conditional statement to check against.",
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
    ]
  },
  {
    "type": "TEXT",
    "name": "dataLayerKey",
    "displayName": "Data Layer Key",
    "simpleValueType": true,
    "help": "Fill in the dataLayer key using just the name of the key itself. If you have nested keys, ie. { meta : { country : \u0027nl\u0027, language : \u0027en\u0027} then use dot notation, ie. meta.country or meta.language. *NOTE* Make sure to add every key being monitored to the Permissions.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "RADIO",
    "name": "required",
    "displayName": "Required?",
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
    "simpleValueType": true
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
    "simpleValueType": true
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
    "displayName": "Debug Mode Variable"
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Required Modules
const log = require("logToConsole");
const getType = require('getType');
const copyFromDataLayer = require("copyFromDataLayer");
const createQueue = require('createQueue');

const addValidationError = createQueue('elevar_gtm_errors');

// Object path traversal function
const deepValue = (obj, path) => path.split(".").reduce((a, v) => a[v], obj);

/**
Function to add new error to validation_errors

@params
message - error message
error_id - id that can be used to identify errors
*/
const addError = (eventId, dataLayerKey, variableName) => (value, condition, expected) => {
  log('GTM Error: ', {
    eventId: eventId,
  	dataLayerKey: dataLayerKey,
    variableName: variableName,
    error: {
      value: value,
      condition: condition,
      conditionValue: expected,
    }
  });
  
  addValidationError({
    eventId: eventId,
    dataLayerKey: dataLayerKey,
    variableName: variableName,
    error: {
      message: dataLayerKey + '=' + value + ' ' + condition + ' ' + expected,
      value: value,
      condition: condition,
      conditionValue: expected,
    }
  });
};

const newError = addError(data.gtmEventId, data.dataLayerKey, data.variableName);

const isValid = (value, condition, expectedValue) => {
  switch (condition) {
    case "equals":
      if (value !== expectedValue) {
        return false;
      }
      return true;

    case "contains":
      if (value.indexOf(expectedValue) === -1) {
        return false;
      }
      return true;

    case "startsWith":
      if (!value.startsWith(expectedValue)) {
        return false;
      }
      return true;

    case "endsWith":
      if (!value.endsWith(expectedValue)) {
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
      if (value.indexOf(expectedValue) > -1) {
        return false;
      }
      return true;

    case "notStartWith":
      if (value.startsWith(expectedValue)) {
        return false;
      }
      return true;

    case "notEndWith":
      if (value.endsWith(expectedValue)) {
        return false;
      }
      return true;

    case "hasLengthOf":
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
  for (let i = 0; i < table.length; i++) {
    if (!isValid(value, table[i].condition, table[i].conditionValue)) {
      newError(value, table[i].condition, table[i].conditionValue);
    }
  }
};

// value type === object
// for each row in table look for key and validate
const validateObject = (item, table) => {
  for (let i = 0; i < table.length; i++) {
    if (!isValid(item[table[i].key], table[i].condition, table[i].conditionValue)) {
      newError(item[table[i].key], table[i].condition, table[i].conditionValue);
    }
  }
};

// value type === array
// for each item in array run validation
const validateArray = (arr, table) => {
  for (let i = 0; i < arr.length; i++) {
    if (typeof arr[i] === 'object') {
      validateObject(arr[i], table);
    } else {
      validateValue(arr[i], table);
    }
  }
};

// Custom dataLayer get function to fix permission error
const getDataLayerValue = key => {
  if (key.indexOf(".0") !== -1) {
    const split = key.split(".0");
	const initialValue = copyFromDataLayer(split[0]);
    if (!initialValue) return initialValue;
    
    return split.slice(1).reduce((a, v) => {
      if (getType(a) !== "array") return undefined;
      if (!v) return a[0];
      
      return deepValue(a[0], v.slice(1));
    }, initialValue);
  }
  return copyFromDataLayer(key);
};

const validationTable = data.validationTable;
const valueType = data.valueType;
const debugMode = data.debugMode;
const dataLayerValue = getDataLayerValue(data.dataLayerKey);

// Don't validate if item is undefined
// But add error if item is required
if (!debugMode) {
  if (typeof dataLayerValue === 'undefined') {
    if (data.required === true) {
      newError(dataLayerValue, 'required', 'true');
    }
  } else {
    switch (valueType) {
      case "value":
          validateValue(dataLayerValue, validationTable);
        break;

      case 'object':
        if (getType(dataLayerValue) !== 'object') {
          newError(dataLayerValue, 'typeOf', 'object');
        }
        validateObject(dataLayerValue, validationTable);
        break;

      case 'array': 
        if (getType(dataLayerValue) !== 'array') {
          newError(dataLayerValue, 'typeOf', 'array');
        }
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
            "string": "all"
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

scenarios: []
setup: ''


___NOTES___

Created on 9/13/2019, 3:02:56 PM


