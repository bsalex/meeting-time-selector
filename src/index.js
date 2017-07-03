import './index.html';
import './styles.css';
import Elm from './App';

const app = Elm.App.embed(document.getElementById('main'));

const service = new google.maps.places.AutocompleteService();
app.ports.getPlacesSuggestions.subscribe(([index, input]) => {
    if (input === '') {
        app.ports.setPlacesSuggestions.send([index, []]);
    } else {
        service.getQueryPredictions({ input, types: "(cities)" }, (suggestions) => {
            app.ports.setPlacesSuggestions.send([index, suggestions.filter((suggestion) => suggestion.place_id)]);
        });
    }
});
