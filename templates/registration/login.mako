<%inherit file="../layout.mako" />

<%def name="title()">Login</%def>
<%def name="bigtitle()">${self.title()}</%def>





<div class="span-24 last" align="center">
    <h1>TSA Events</h1>
    % if error_msg:
      <div class="error">
        ${error_msg}
      </div>
    % endif
    
</div>

<div class="span-14">

  <p>TSAEvents.com is a web-based system to streamline the day-to-day operations of a TSA chapter. Each chapter member can create an account to manage their own status, sign up for events, form teams, and communicate with team members. Advisors can easily manage their chapter and view detailed summaries of it. See the <a href="/help/member_guide">member guide</a> and <a href="/help/advisor_guide">advisor guide</a> for tours of the system.</p>
  
  
  <h3>Create new account</h3>
  
  <p>If your chapter is using the system, create a new account with the form below.</p>
  
  <form action="/accounts/create" method="get">
    <table class="layouttable aligner">
      <tr>
        <th>
          Chapter:
        </th>
        <td>
          <select name="chapter">
            <option value="-1">---- Select chapter ----</option>
            % for c in chapters:
              <option value="${c.id}">[${c.event_set.level}][${c.event_set.state}][${c.event_set.region[-1]}] ${c.name}</option>
            % endfor
          </select>
          <input type="submit" value="Continue">
        </td>
      </tr>
    </table>
  </form>
  
  <p></p>
  
  <h3>Create new chapter</h3>
  
  <p>Interested in using this system for your own chapter? The system is currently in open beta and available free to any chapter in Pennsylvania. Email <a href="mailto:admin@tsaevents.com">admin@tsaevents.com</a> for more information.

</div>


<div class="span-10 last" align="center">
  

  
  
  <form action='/accounts/login/' method='post'>
  
  <table class="layouttable aligner">

    <tr>
      <td colspan="2" style="text-align: center;">
          <h2>User Login</h2>
      </td>
    </tr>
    
    ${form.as_table()}

    <tr>
      <td>&nbsp;</td>
      <td>
        <input type="submit" value="Log in" />
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