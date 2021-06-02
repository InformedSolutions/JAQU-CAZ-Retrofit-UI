require("@rails/ujs").start();

import '../styles/application.scss';
import '../src/GovUKAssets';
import { initAll } from 'govuk-frontend/govuk/all.js';
import cookieControl from "../src/cookieControl";

document.body.classList.add('js-enabled');

initAll();
cookieControl();
