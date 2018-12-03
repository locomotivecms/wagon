class Manager {

  constructor() {
    this.sections = {};
  }

  registerSection(type, actions) {
    console.log(type, actions);
    this.sections[type] = actions;
  }

  start() {
    this.eachType((type, actions) => {
      this.queryAll(`.locomotive-section[data-locomotive-section-type="${type}"]`).forEach((section, index) => {
        this.runAction(actions, 'load', section);
      });
    });
    this.registerEvents();

    window._sectionsManager = this;
  }

  registerEvents() {
    const events = {
      section: ['load', 'unload', 'select', 'deselect', 'reorder'],
      block: ['select', 'deselect']
    }

    for (var namespace in events) {
      events[namespace].forEach(eventType => {
        const eventName = `locomotive::${namespace}::${eventType}`;
        const actionName = this.eventTypeToActionName(namespace, eventType);

        document.addEventListener(eventName, event => {
          this.applyRuleToEvent(actionName, event);
        });
      });
    }
  }

  applyRuleToEvent(actionName, event) {
    const { sectionId, blockId } = event.detail;
    const section   = document.getElementById(`locomotive-section-${sectionId}`);
    const type      = section.getAttribute('data-locomotive-section-type');
    const block     = this.queryOne(`[data-locomotive-block="section-${sectionId}-block-${blockId}"]`, section);

    this.runAction(this.sections[type], actionName, section, block)
  }

  eventTypeToActionName(namespace, eventType) {
    if (namespace === 'section')
      return eventType;
    else
      return namespace + eventType.charAt(0).toUpperCase() + eventType.slice(1);
  }

  runAction(actions, actionName, section, block) {
    const action = actions[actionName];

    if (action !== undefined)
      action(section, block);
  }

  eachType(callback) {
    for (var type in this.sections) {
      const actions = this.sections[type];
      callback(type, actions)
    }
  }

  queryAll(selector, scope) {
    scope = scope ? scope : document;
    return scope.querySelectorAll(selector);
  }

  queryOne(selector, scope) {
    scope = scope ? scope : document;
    return scope.querySelector(selector);
  }

  testAction(eventType, section, block) {
    const hasBlock  = block !== undefined && block !== null ;
    const namespace = hasBlock ? 'block' : 'section';
    const sectionId = section.getAttribute('id').replace('locomotive-section-', '');
    const blockId   = hasBlock ? block.getAttribute('data-locomotive-block').replace(`section-${sectionId}-block-`, '') : null;
    const detail    = { detail: { sectionId, blockId } };
    const eventName = `locomotive::${namespace}::${eventType}`;

    document.dispatchEvent(new CustomEvent(eventName, detail));
  }

}

export default Manager;
