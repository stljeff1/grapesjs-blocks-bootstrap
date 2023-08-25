export const ListItemBlock = (bm, label) => {
    bm.add('list_item', {
        label: label,
        category: 'Basic',
        attributes: {class: 'fa fa-list'},
        content: {
            type: 'list_item',
            content: `<li>This is a list.</li>`,            
        }
    });
};

export default (domc) => {
    const defaultType = domc.getType('default');
    const defaultModel = defaultType.model;

    const textType = domc.getType("text")
    const textView = textType.view;    

    domc.addType('list_item', {
        model: defaultModel.extend({
            defaults: Object.assign({}, defaultModel.prototype.defaults, {
                'custom-name': 'ListItem',
                tagName: 'li',
                resizable: false,
                draggable: ["ul","ol"],
                dropable: false,
                editable: true,
                traits: [
                ].concat(defaultModel.prototype.defaults.traits)
            })
        }, {
            isComponent: function (el) {
                if (el && el.tagName === "LI") {
                    return {type: 'list_item'};
                }
            }
        }),
        view: textView
    });
    
}
