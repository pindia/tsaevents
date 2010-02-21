<%inherit file="../layout.mako" />

<%def name="title()">Login</%def>
<%def name="bigtitle()">${self.title()}</%def>



<div class="span-24 last" align="center">
  <h1>TSA Events - Login</h1>
  <p>Log in below with your username and password, or simply use the link in your email.</p>
</div>

<div class="span-24 last" align="center">
  
  
  <form action='/accounts/login/' method='post'>
  
  <table class="layouttable">

    

    % if error:
      <tr class="error">
        <td colspan="2">
        Sorry, that's not a valid username or password</td>
      </tr>
    % endif
    
    ${form.as_table()}

    <tr>
      <td>&nbsp;</td>
      <td><input type="submit" value="Log in" />&nbsp;&nbsp;or&nbsp;&nbsp;<a href="/accounts/create">Create&nbsp;Account</a>
      <input type="hidden" name="next" value="/"/> 
      </td>
    </tr>

  </table>

  </form>
  
</div>