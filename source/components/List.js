export const ListBlock = (bm, label) => {
    bm.add('list', {
        label: label,
        category: 'Basic',
        attributes: {class: 'fa fa-list'},
        content: {
            type: 'list',
            content: `
<ul class="list-unstyled">
  <li>This is a list.</li>
</ul>
      `,
        }
    });
};

export default (domc) => {
    const defaultType = domc.getType('default');
    const defaultModel = defaultType.model;
    const defaultView = defaultType.view;

    domc.addType('list', {
        model: defaultModel.extend({
            defaults: Object.assign({}, defaultModel.prototype.defaults, {
                'custom-name': 'List',
                tagName: 'ul',
                resizable: 1,
                dropable: "li",
                traits: [
                    {
                        type: 'select',
                        options: [
                            {value: 'ul', name: 'No'},
                            {value: 'ol', name: 'Yes'}
                        ],
                        label: 'Ordered?',
                        name: 'tagName',
                        changeProp: 1
                    }
                ].concat(defaultModel.prototype.defaults.traits)
            })
        }, {
            isComponent: function (el) {
                if (el && ['UL', 'OL'].includes(el.tagName)) {
                    return {type: 'list'};
                }
            }
        }),
        view: defaultView
    });
}
