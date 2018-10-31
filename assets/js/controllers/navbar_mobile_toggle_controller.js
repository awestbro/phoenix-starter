import { Controller } from "stimulus";

export default class extends Controller {
  toggle() {
    const target = this.element.dataset.target;
    const $target = document.getElementById(target);
    // Toggle the class on both the "navbar-burger" and the "navbar-menu"
    this.element.classList.toggle('is-active');
    $target.classList.toggle('is-active');
  }
}
