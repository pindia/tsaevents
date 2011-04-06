<%def name="footer()">Copyright &copy; <a href="http://www.pindi.us">Pindi Albert</a></%def>
<%def name="header()">Welcome to TSAEvents.com</%def>
<%def name="title()"></%def>
<%def name="bigtitle()"></%def>
<%def name="scripts()"></%def>


<html>
<head>
    <title>TSA Events - ${self.title()}</title>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
    <link rel="stylesheet" href="/static/tsa/blueprint/screen.css" type="text/css" media="screen, projection">
    <link rel="stylesheet" href="/static/tsa/blueprint/print.css" type="text/css" media="print">	
    <!--[if lt IE 8]><link rel="stylesheet" href="/static/tsa/blueprint/ie.css" type="text/css" media="screen, projection"><![endif]-->
    <link rel="stylesheet" href="/static/tsa/style.css"> 
    ${self.scripts()}
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
  
% if (DEPLOYED) and (not user or not user.is_superuser):
  
    <script type="text/javascript">
    var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
    document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
    </script>
    <script type="text/javascript">
    try {
    var pageTracker = _gat._getTracker("UA-195288-7");
    % if chapter:
        pageTracker._setCustomVar(1,"chapter","${chapter.name}",3);
    % endif
    % if user:
        pageTracker._setCustomVar(2,"username","${user.username}",3);
    % endif
    pageTracker._trackPageview();
    } catch(err) {}</script>
    
% endif
  
  
</body>
</html>

