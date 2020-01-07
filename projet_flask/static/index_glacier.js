var mymap = L.map('map').setView([46.6, 8.6], 8);



// Définir les différentes couches de base:
var osmLayer = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
  attribution: '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
});
var terrain= L.tileLayer('http://{s}.tile3.opencyclemap.org/landscape/{z}/{x}/{y}.png',{
  attribution: '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
});
osmLayer.addTo(mymap);

var baseLayers = {
  "Fond de carte OpenStreetMap": osmLayer,
  "Fond de carte Terrain": terrain
};
var overlays = {};


// Ajouter la couche de base par défaut à la carte.
L.control.layers(baseLayers, overlays).addTo(mymap);

var marqueurs = [];

function show_glaciers(){
//Il faut d'abord enlever tous les marqueurs qui sont déjà existants
  // for (var i=0; i < marqueurs.length; i++){
  //  mymap.removeLayer(marqueurs[i]);
  //}
  //var region= $('#region').val();
  var url = '/glaciers_info.json';
  //if(region != '') url = '/'+region+'/glaciers_info.json';

  $.getJSON(url, function(data){
    for (var i=0; i <data.length; i++){
      var glacier = data[i];
      ajouter_marqueur_glacier(glacier); //on nomme une fonction ajouter_marqueur_glacier qu'on définira par la suite
    }
  });
  //console.log(marqueurs);
}

//on va chercher les données json et on les affiche dans la console


show_glaciers();

var groupe_marqueurs= L.layerGroup(marqueurs);
//apparition des marqueurs seulement en zoomant (fonctionne pas)
mymap.on('zoomend', function(){
  if(mymap.getZoom() < 12){
    mymap.removeLayer(groupe_marqueurs);
  } else{
    mymap.addLayer(groupe_marqueurs);
  }
});

//coordonnée
mymap.on('mousemove', function(e){
  var coord = e.latlng;
  $('#coordonnees').html('Coordonnées: ' + coord.lat.toFixed(5) +' / '+ coord.lng.toFixed(5));
});



function ajouter_marqueur_glacier(glacier){
  var m = L.marker([glacier.y, glacier.x]).addTo(mymap);
  marqueurs.push(m)
  //le m.on(click) ne fonctionne pas correctement
  m.on('click', function(e){
    //var glacier = e.target.marqueurs;
    var html = '<td>les glaciers suisse</td>';
    $('infobox').html(html);
    mymap.panTo(([glacier.y, glacier.x]),{animate: true});
    mymap.flyTo(([glacier.y, glacier.x]),14);

    afficher_graphique_glacier(glacier);
  })
}

//SELON MOI IL MANQUE UNE PARTIE ICI POUR AFFICHER LE GRAPHIQUE
function afficher_graphique_glacier(glacier){
  var id_glacier = glacier.id.replace('/', '-'); //transformation des / en - car ils peuvent poser problème
  $.getJSON('/length/'+id_glacier+'.json', function(data){
    draw_graphique_length(data);
  });
}

function draw_graphique_length(data){

  //console.log('draw_graphique_length', data)
  var graphique_donnees = data.lengths;
  console.log('draw_graphique_length', graphique_donnees)
  //paramètres de base
  var width = 300;
  var height = 200;

  var parseTime = d3.timeParse("%Y-%m-%d");
  var dateFormat = d3.timeFormat("%d.%m.%Y");

  //projection pour les axes
  var x = d3.scaleTime().range([0, width]);
  var y = d3.scaleLinear().range([height, 0]);

    //fonction qui définira la courbe du graphique
  var line = d3.line()
    .x(function(d) { return x(d[0]); }) // la fonction se fait sur les données on reprend la ligne 0 et 1 du length.json pour avoir les données
    .y(function(d) { return y(d[1]); });

  // création du svg
  $('#graph_length').html(''); // on reprend le div du graphe
  var svg = d3.select("#graph_length").append("svg")
    .attr("id", "svg")
    .attr("width", width)
    .attr("height", height)
    .append("g");


  // Contrairement au tutoriel Bar Chart, plutôt que de prendre un range entre 0 et le max on demande
  // directement à D3JS de nous donner le min et le max avec la fonction 'd3.extent', pour la date comme
  // pour le cours de fermeture (close).
  x.domain(d3.extent(data, function(d) { return d[0]; })); //même chose pour ses deux lignes où on reprends les données
  y.domain(d3.extent(data, function(d) { return d[1]; }));

  // Ajout de l'axe X
  svg.append("g")
      .attr("transform", "translate(0," + height/2 + ")")
      .call(d3.axisBottom(x));

  // Ajout de l'axe Y et du texte associé pour la légende
  svg.append("g")
      .call(d3.axisLeft(y))
      .append("text")
          .attr("fill", "#000")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr("dy", "0.71em")
          .style("text-anchor", "end")
          .text("Longueur");

  // Ajout de la grille horizontale (pour l'axe Y donc). Pour chaque tiret (ticks), on ajoute une ligne qui va
  // de la gauche à la droite du graphique et qui se situe à la bonne hauteur.
  svg.selectAll("y axis").data(y.ticks(10))
    .enter()
    .append("line")
    .attr("class", "horizontalGrid")
    .attr("x1", 0)
    .attr("x2", width)
    .attr("y1", function(d){ return y(d[1]);})
    .attr("y2", function(d){ return y(d[1]);});

  // Ajout d'un path calculé par la fonction line à partir des données de notre fichier.
  svg.append("path")
      .datum(graphique_donnees)
      .attr("class", "line")
      .attr("d", line);

}
