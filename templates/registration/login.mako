<%inherit file="../layout.mako" />

<%def name="title()">Login</%def>
<%def name="bigtitle()">${self.title()}</%def>





<div class="span-24 last" align="center">

    % if error_msg:
      <div class="error">
        ${error_msg}
      </div>
    % endif

  <h1>TSA Events - Login</h1>
  <p>Log in below with your username and password.</p>
  
  
  <form action='/accounts/login/' method='post'>
  
  <table class="layouttable aligner">

    
    
    ${form.as_table()}

    <tr>
      <td>&nbsp;</td>
      <td>
        <input type="submit" value="Log in" />&nbsp;&nbsp;or&nbsp;&nbsp;<a href="/accounts/create/">Create&nbsp;Account</a>
        <input type="hidden" name="next" value="${next or '/'}"/> 
      </td>
    </tr>

    <tr>
      <td>&nbsp;</td>
      <td>
        <a href="/accounts/reset/">Forgot password?</a>
      </td>
    </tr>

  </table>

  </form>
  
</div>