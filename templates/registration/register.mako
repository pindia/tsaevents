<html>
<head>
<link rel="stylesheet" href="/static/tsa/style.css">
</head>
<body>

<h2>Create Account</h2>

<form action="/accounts/create/" method='post'>
    
    <table>     
        ${form.as_table()}
    </table>

    <input type="submit" value="Create" /> 
  
</form>
  
</body>
</html>

