import { Controller } from "stimulus"

export default class extends Controller {
  close() {
    const notification = this.element;
    const section = notification.parentNode;
    section.removeChild(notification);
    if (section.innerHTML.trim() === "") {
      section.parentElement.removeChild(section);
    }
  }
}
