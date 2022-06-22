new Text('Hello world').addTo(stage);

new Bitmap('images/pokemonbg.png')
 .addTo(stage)
 .attr('filters', [
    filter.opacity(0.13),
    filter.grayscale(1),
    filter.blur(3),
    filter.invert(2)
  ]);;