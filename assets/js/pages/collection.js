function searchInputFilterHandler(event) {
  const text = event.target.value;
  console.log("Search text change: ", text);
}

document.addEventListener('DOMContentLoaded',function() {
  console.log("Adding event thing");
  document.querySelector('select[id="collection-filter"]').onchange = searchInputFilterHandler;
},false);

