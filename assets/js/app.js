import "phoenix"
import "phoenix_html"
import "./util/bulma"

// Authentication

let authenticated = false;
let token;
let header_string;

const token_element = document.querySelector('meta[name="guardian_token"]');

if (token_element) {
  token = token_element.getAttribute('content');
  header_string = `Bearer: ${token}`;
  authenticated = true;
}
