<!DOCTYPE html>
<%def name="footer()">Copyright &copy; <a href="http://www.pindi.us">Pindi Albert</a></%def>
<%def name="header()">Welcome to TSAEvents.com</%def>
<%def name="title()"></%def>
<%def name="bigtitle()"></%def>
<%def name="scripts()"></%def>


<html>
<head>
    <title>TSA Events - ${self.title()}</title>
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script type="text/javascript" src="/static/tsa/bootstrap/bootstrap.min.js"></script>


    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="/static/tsa/bootstrap/bootstrap.min.css">
    <link rel="stylesheet" href="/static/tsa/bootstrap/bootstrap-responsive.min.css">

    <link rel="stylesheet" href="/static/tsa/style.css"> 
    ${self.scripts()}
</head>
<body>
  <div class="container">

        <div class="row">
            <div id="header" class="span12" align="center">
                ${self.header()}
            </div>
        </div>

        ${next.body()}

        <div class="row">
            <div class="span12" id="footer">
              ${self.footer()}
            </div>
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

