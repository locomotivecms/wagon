// === Wagon main javascript file ===

// Tell Webpack to load the style
import '../stylesheets/app.scss';

// Import the classes required to handle sections
import SectionsManager from './sections/_manager';
import * as Sections from './sections';

document.addEventListener('DOMContentLoaded', event => {

  // Load all the sections
  const sectionsManager = new SectionsManager();

  // Register sections here. DO NOT REMOVE OR UPDATE THIS LINE

  sectionsManager.start();

});
