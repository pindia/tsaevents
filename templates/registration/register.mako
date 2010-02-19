<html>
<head>
<link rel="stylesheet" href="/static/tsa/style.css">
<link rel="stylesheet" href="">

<link rel="stylesheet" href="/static/tsa/blueprint/screen.css" type="text/css" media="screen, projection">
<link rel="stylesheet" href="/static/tsa/blueprint/print.css" type="text/css" media="print">	
<!--[if lt IE 8]><link rel="stylesheet" href="/static/tsa/blueprint/ie.css" type="text/css" media="screen, projection"><![endif]-->

</head>
<body>

 <div class="container">


    <div id="header" class="span-24 last ui-widget-header" align="center">Welcome to TSAEvents.com</div>

    <div class="span-24 last" align="center">
      <h2>TSA Events &gt; Create Account</h2>
    </div>


    <div class="span-24 last" align="center">

<form action="/accounts/create/" method='post'>
    
    <table class="datatable">     
        ${form.as_table()}
      <tr ><td colspan="2"><div align="center"><input type="submit" value="Create" /></div></td></tr>
    </table>

    </div>

</form>

    <div class="span-24 last" id="footer">
      Copyright &copy; <a href="http://www.pindi.us">Pindi Albert</a>
    </div>

  </div>

</body>
</html>

