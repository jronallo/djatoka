//////////////////////
//$.extend({
//  getUrlVars: function(){
//    var vars = [], hash;
//    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
//    for(var i = 0; i < hashes.length; i++)
//    {
//      hash = hashes[i].split('=');
//      vars.push(hash[0]);
//      vars[hash[0]] = hash[1];
//    }
//    return vars;
//  },
//  getUrlVar: function(name){
//    return $.getUrlVars()[name];
//  }
//});
//////////////////////////////

   function openlayersInit(base_url,metadataUrl, rft_id, div_identifier){

	//alert(params);
        //var metadataUrl = "http://localhost/adore-djatoka/resolver?url_ver=Z39.88-2004&rft_id=http://memory.loc.gov/gmd/gmd433/g4330/g4330/np000066.jp2&svc_id=info:lanl-repo/svc/getMetadata";

        var OUlayer = new OpenLayers.Layer.OpenURL( "OpenURL",
          base_url, {layername: 'basic',
format:'image/jpeg',
rft_id: rft_id,
metadataUrl: metadataUrl} );
        var metadata = OUlayer.getImageMetadata();
        var resolutions = OUlayer.getResolutions();
        var maxExtent = new OpenLayers.Bounds(0, 0, metadata.width,
metadata.height);
        var tileSize = OUlayer.getTileSize();
        var options = {resolutions: resolutions, maxExtent: maxExtent,
tileSize: tileSize};
        var map = new OpenLayers.Map( div_identifier, options);
        map.addLayer(OUlayer);
        var lon = metadata.width / 2;
        var lat = metadata.height / 2;
        map.setCenter(new OpenLayers.LonLat(lon, lat), 0);
      }
///////////////////////////////////////
//     $(document).ready(function() {
//   openlayersInit('http://localhost',"http://localhost/adore-djatoka/resolver?url_ver=Z39.88-2004&rft_id=http://memory.loc.gov/gmd/gmd433/g4330/g4330/np000066.jp2&svc_id=info:lanl-repo/svc/getMetadata",
//   'http://memory.loc.gov/gmd/gmd433/g4330/g4330/np000066.jp2');
// });

