
function check_response_status_codes(responses, success_code) {
  for (const response of responses) {
    if (response.statusCode != success_code) {
      return response.statusCode;
    }
  }
  return success_code;
}

global.check_response_status_codes = check_response_status_codes;
