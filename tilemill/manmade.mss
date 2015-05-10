#buildings[zoom>=14] {
  line-width: 0;
  polygon-opacity: 1;
  polygon-fill: @darkgrey;
}

#residental[zoom>=10] {
  polygon-fill:@grey;
  polygon-opacity: 0;
  [zoom>=10][zoom<14]{
  	polygon-opacity:1;
  }  
  [zoom>=14][zoom<15]{
    polygon-opacity:0.55;
  }  
  [zoom>=15] {
    polygon-opacity:0.5;
  }
}

#industrial[zoom>=10] {
  polygon-fill: @industrial;
  polygon-opacity: 1;
}

#military {
  polygon-pattern-file:url(img/stripes-red.png);
  polygon-pattern-opacity: 0.2;
  line-width: 0.2;
  line-color: red;
}

// to-do: improve SQL query to merge nearby lines
#railway[zoom>=10] {
  ::line {
    line-width: 0.5;
    [zoom>=9][zoom<11] {
      line-width: 0.8;
    }
    [zoom>=11][zoom<12] {
      line-width: 1;
    }
    [zoom>=12][zoom<13] {
      line-width: 2.5;
    }
    [zoom>=13][zoom<=14] {
      line-width: 3.5;
    }
    [zoom>14] {
      line-width: 4.5;
    }
    line-color: @darkgrey;
  }
  ::dash[zoom>=12] {
    line-color: white;
    line-width: 1.2;
    line-dasharray: 9, 9;
    [zoom>=13][zoom<=14] {
      line-width: 2;
      line-dasharray: 13, 13;
    }
    [zoom>14] {
      line-width: 2.5;
      line-dasharray: 18, 16;
    }  
    
  }
}

.power[zoom>=14] {
  ::lines {
    line-width:0.5;
    line-color:black;
  }
  ::tower {
    marker-file: url(img/square.svg);
    marker-width:3;
    marker-fill:black;
//    marker-allow-overlap:true;
//    marker-ignore-placement:true;
  }	  
}




#runway[zoom>=10] {
  ::line{
    line-width: 12;
  	line-color:@runway;
  }
  ::dash{
    line-color: white;
    line-width: 2;
    line-dasharray: 9, 9;
  }  
}
