// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

import Hooks from "./hooks";
import makeDraggable from "./drag";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

const container = document.getElementById('mapping');

// Create an SVG element
const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
//container.removeChild(svg);

// Set the SVG attributes
svg.setAttribute('width', '100%');
svg.setAttribute('height', '100%');
svg.setAttribute('class', 'z-0 absolute');

function place_points(leds) { 
    
    let first = leds[0]
    let last = leds[leds.length -1]

    /*
    console.log(leds)
    console.log(first)
    console.log(last)
    console.log(first.getAttribute('phx-value-width'))
    console.log(first.getAttribute('phx-value-height'))
    console.log(first.getAttribute('phx-value-vmin'))
    console.log(parseFloat(first.getAttribute('phx-value-vmin')) + parseFloat(first.getAttribute('phx-value-height')))
    */

    // Get the bounding rectangle of the div
    //let rect_first = first.getBoundingClientRect();
    //let rect_last = last.getBoundingClientRect();

    let start_point = document.getElementById('startpoint');
    let end_point = document.getElementById('endpoint');

    start_point.style.top = (parseFloat(first.getAttribute('phx-value-vmin')) + (parseFloat(first.getAttribute('phx-value-height'))/2 - 6 )) + 'px';
    start_point.style.left = (parseFloat(first.getAttribute('phx-value-hmin')) + (parseFloat(first.getAttribute('phx-value-width'))/2 - 6 )) + 'px';
    end_point.style.top = (parseFloat(last.getAttribute('phx-value-vmin')) + (parseFloat(last.getAttribute('phx-value-height'))/2 - 6 )) + 'px';
    end_point.style.left = (parseFloat(last.getAttribute('phx-value-hmin')) + (parseFloat(last.getAttribute('phx-value-width'))/2 - 6 )) + 'px';

    makeDraggable(start_point);
    makeDraggable(end_point);

    window.dispatchEvent(point_event, {id: 'startpoint', left: start_point.style.left, top: start_point.style.top});
    window.dispatchEvent(point_event, {id: 'endpoint', left: end_point.style.left, top: end_point.style.top});
 }


//document.addEventListener('DOMContentLoaded', function() {
window.addEventListener("phx:select-stripe", (e) => {
    console.log("select stripe")
    console.log(e)
    
    let leds = container.querySelectorAll('.led');
    if( leds.length > 0 ) {
        place_points(leds);
    }
    let points = container.querySelectorAll('.point');
    //console.log(points)
    points.forEach(point => {
        makeDraggable(point);
    });
});


//document.addEventListener('DOMContentLoaded', function() {
window.addEventListener("phx:resize-window", (e) => {
    console.log("select stripe")
    console.log(e)
   
    let leds = container.querySelectorAll('.led');
    if( leds.length > 0 ) {
        place_points(leds);
    }
});


//document.addEventListener('DOMContentLoaded', function() {
window.addEventListener("phx:select-stripe_bak", (e) => {

    console.log(e)

    let points = container.querySelectorAll('.point');
    const lines = svg.querySelectorAll('line');
    lines.forEach(line => line.remove());

    container.addEventListener('mousedown', function(event) {
        
        console.log(event)

        if (points.length < 2) {
            const point = document.createElement('div');
            point.style.top = (event.offsetY - 6) + 'px';
            point.style.left = (event.offsetX - 6) + 'px';
            point.className = "z-10 draggable point absolute";
            point.setAttribute('phx-value-top', event.offsetY);
            point.setAttribute('phx-value-left', event.offsetX);
            container.appendChild(point);
        }
            
        points = container.querySelectorAll('.point');

        if (points.length == 2) {
            console.log(points[0]);

            points.forEach(point => {
                //makeDraggable(point);
            });

            // Create a line element
            const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');

            line.setAttribute('style', "stroke:black;stroke-width:4");
            line.setAttribute('stroke', 'black'); // Set line color
            line.setAttribute('stroke-width', '4'); // Set line width

            // Append the line to the SVG
            
            console.log(svg)

            
            line.setAttribute('x1', points[0].getAttribute('phx-value-left'));
            line.setAttribute('y1', points[0].getAttribute('phx-value-top'));
            line.setAttribute('x2', points[1].getAttribute('phx-value-left'));
            line.setAttribute('y2', points[1].getAttribute('phx-value-top'));
            
            svg.appendChild(line);
            //line.stroke({ color: '#f06', width: 10, linecap: 'round' })
            // Append the SVG to the parent div
            container.appendChild(svg);
        }  
        //console.log(container)
        //<svg width="500" height="500"><line x1="50" y1="50" x2="350" y2="350" stroke="black"/></svg>
    });
});






