<%inherit file="../layout.mako" />

<%def name="title()">Reset Password</%def>
<%def name="bigtitle()">${self.title()}</%def>


<div class="span-24 last" align="center">
    <h1>TSA Events - Reset Password</h1>

    <form action="" method='post'>

        % if error_msg:
            <div class="error">${error_msg}</div>
        % endif
        % if success_msg:
            <div class="info">${success_msg}</div>
        % endif
        
        Enter your username or email address in the form below, and you will be sent a link to reset your password.
        
        <table class="layouttable aligner">     
            <tr>
                <th>Username or Email:</th>
                <td><input type="entry" name="username"></td>
            </tr>
            <tr>
                <td colspan="2"><div align="center"><input type="submit" value="Reset" /></div></td>
            </tr>
        </table>

    </form>

</div>