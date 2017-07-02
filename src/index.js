import './index.html';
import './styles.css';
import Elm from './App';

const service = new google.maps.places.AutocompleteService();
service.getQueryPredictions({ input: 'pizza near Syd' }, displaySuggestions);

const app = Elm.App.embed(document.getElementById('main'), {
    token: "123"
});
