package annotationvalidation

test_input_no_validation {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "annotation"},
    }}},
    "parameters": {},
  }

  count(results) == 0
}

test_input_no_validation {
  results := violation with input as {
    "review": {"object": {"metadata": {"name": "somename"}}},
    "parameters": {},
  }

  count(results) == 0
}

test_input_has_annotation {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "annotation"},
    }}},
    "parameters": {"annotations": [{
      "key": "some",
      "allowedRegex": "annotation",
    }]},
  }

  count(results) == 0
}

test_input_has_extra_annotation {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "annotation", "new": "thing"},
    }}},
    "parameters": {"annotations": [{
      "key": "some",
      "allowedRegex": "annotation",
    }]},
  }

  count(results) == 0
}

test_input_has_extra_annotation_req2 {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "annotation", "new": "thing"},
    }}},
    "parameters": {"annotations": [
      {
        "key": "some",
        "allowedRegex": "annotation",
      },
      {
        "key": "new",
        "allowedRegex": "thing",
      },
    ]},
  }

  count(results) == 0
}

test_input_missing_annotation {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some_other": "annotation"},
    }}},
    "parameters": {"annotations": [{
      "key": "some",
      "allowedRegex": "annotation",
    }]},
  }

  count(results) == 0
}

test_input_one_missing {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "annotation"},
    }}},
    "parameters": {"annotations": [
      {
        "key": "some",
        "allowedRegex": "annotation",
      },
      {
        "key": "new",
        "allowedRegex": "thing",
      },
    ]},
  }

  count(results) == 0
}

test_input_empty {
  results := violation with input as {
    "review": {"object": {"metadata": {"name": "somename"}}},
    "parameters": {"annotations": [{
      "key": "some",
      "allowedRegex": "annotation$",
    }]},
  }

  count(results) == 0
}

test_input_two_allowed {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "grey", "other": "gray"},
    }}},
    "parameters": {"annotations": [
      {
        "key": "some",
        "allowedRegex": "gr[ae]y",
      },
      {
        "key": "other",
        "allowedRegex": "gr[ae]y",
      },
    ]},
  }

  count(results) == 0
}

test_input_wrong_value {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "annotation2"},
    }}},
    "parameters": {"annotations": [{
      "key": "some",
      "allowedRegex": "annotation$",
    }]},
  }

  count(results) == 1
}

test_input_wrong_value_extra_annotation {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "annotation2", "some_other": "annotation"},
    }}},
    "parameters": {"annotations": [{
      "key": "some",
      "allowedRegex": "annotation$",
    }]},
  }

  count(results) == 1
}

test_input_two_wrong {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "greyish", "other": "grayish"},
    }}},
    "parameters": {"annotations": [
      {
        "key": "some",
        "allowedRegex": "gr[ae]y$",
      },
      {
        "key": "other",
        "allowedRegex": "gr[ae]y$",
      },
    ]},
  }

  count(results) == 2
}

test_input_message {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"some": "annotation2"},
    }}},
    "parameters": {
      "message": "WRONG_VALUE",
      "annotations": [{
        "key": "some",
        "allowedRegex": "annotation$",
      }],
    },
  }

  results[_].msg == "WRONG_VALUE"
}

# test a relatively complicated regex: matching an AWS role arn
test_input_arn_pattern {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"arn": "arn:aws:iam::123456789012:role/aws-service-role/lex.amazonaws.com/AWSServiceRoleForLexBots"},
    }}},
    "parameters": {"annotations": [{
      "key": "arn",
      "allowedRegex": "^arn:aws:iam::[0-9]+:role((/)|(/[\\x21-\\x7f]+/))[\\w+=,.@-]+$",
    }]},
  }

  count(results) == 0
}

test_input_arn_pattern_invalid {
  results := violation with input as {
    "review": {"object": {"metadata": {
      "name": "somename",
      "annotations": {"arn": "arn:aws:iam:123456789012:role/aws-service-role/lex.amazonaws.com/AWSServiceRoleForLexBots"},
    }}},
    "parameters": {"annotations": [{
      "key": "arn",
      "allowedRegex": "^arn:aws:iam::[0-9]+:role((/)|(/[\\x21-\\x7f]+/))[\\w+=,.@-]+$",
    }]},
  }

  count(results) == 1
}
