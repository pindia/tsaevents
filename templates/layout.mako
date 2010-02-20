<%def name="footer()">
    Copyright &copy; <a href="http://www.pindi.us">Pindi Albert</a>
</%def>
<%def name="header()">
    Welcome to TSAEvents.com
</%def>
<%def name="title()">
    TSA Events
</%def>



<html>
<head>
    <link rel="stylesheet" href="/static/tsa/style.css">
        
    <link rel="stylesheet" href="/static/tsa/blueprint/screen.css" type="text/css" media="screen, projection">
    <link rel="stylesheet" href="/static/tsa/blueprint/print.css" type="text/css" media="print">	
    <!--[if lt IE 8]><link rel="stylesheet" href="/static/tsa/blueprint/ie.css" type="text/css" media="screen, projection"><![endif]-->
</head>
<body>
  
  <div class="container">


    <div id="header" class="span-24 last ui-widget-header" align="center">
        ${next.header()}    
    </div>

    <div class="span-24 last" align="center">
      <h2>${next.title()}</h2>
    </div>

   
    ${next.body()}

    <div class="span-24 last" id="footer">
      ${next.footer()}  
    </div>

  </div>
  
</body>
</html>