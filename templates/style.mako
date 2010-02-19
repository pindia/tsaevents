<html>

<head>
  <link rel="stylesheet" href="/static/tsa/style.css">
  <link rel="stylesheet" href="">

  <link rel="stylesheet" href="/static/tsa/blueprint/screen.css" type="text/css" media="screen, projection">
  <link rel="stylesheet" href="/static/tsa/blueprint/print.css" type="text/css" media="print">	
  <!--[if lt IE 8]><link rel="stylesheet" href="/static/tsa/blueprint/ie.css" type="text/css" media="screen, projection"><![endif]-->

</head>

<%def name='header()'>
  Welcome to TSAEvents.com
</%def>

<%def name='footer()'>
  Copyright &copy; <a href="http://www.pindi.us">Pindi Albert</a>
</%def>

<body>

  <div class="container">

    <div id="header" class="span-24 last ui-widget-header" align="center">${self.header()}</div>

    ${next.body()}

    <div id="footer" class="span-24 last ui-widget-header" align="center">${self.footer()}</div>
  
  </div>
  
</body>

</html>
