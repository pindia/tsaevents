<%def name="footer()">Copyright &copy; <a href="http://www.pindi.us">Pindi Albert</a></%def>
<%def name="header()">Welcome to TSAEvents.com</%def>
<%def name="title()"></%def>
<%def name="bigtitle()"></%def>
<%def name="scripts()"></%def>


<html>
<head>
    <title>TSA Events - ${self.title()}</title>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
    ${self.scripts()}
    <link rel="stylesheet" href="/static/tsa/blueprint/screen.css" type="text/css" media="screen, projection">
    <link rel="stylesheet" href="/static/tsa/blueprint/print.css" type="text/css" media="print">	
    <!--[if lt IE 8]><link rel="stylesheet" href="/static/tsa/blueprint/ie.css" type="text/css" media="screen, projection"><![endif]-->
    <link rel="stylesheet" href="/static/tsa/style.css"> 
</head>
<body>
  
  <div class="container">


    <div id="header" class="span-24 last ui-widget-header" align="center">
        ${self.header()}    
    </div>

    ${next.body()}

    <div class="span-24 last" id="footer">
      ${self.footer()}  
    </div>

  </div>
  
</body>
</html>

