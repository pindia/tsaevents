<%inherit file="../layout.mako" />

<%def name="title()">Reset Password</%def>
<%def name="bigtitle()">${self.title()}</%def>


<div class="span-24 last" align="center">
    <h1>TSA Events - Reset Password</h1>

    <form action="" method='post'>

        <input type="hidden" name="user" value="${uid}">
        <input type="hidden" name="auth" value="${auth}">

        % if error_msg:
            <div class="error">${error_msg}</div>
        % endif
        % if success_msg:
            <div class="info">${success_msg}</div>
        % endif
        
        Almost done! Enter your new password into the form below.
        
        <table class="layouttable aligner">     
            <tr>
                <th>New password:</th>
                <td><input type="password" name="password"></td>
            </tr>
            <tr>
                <th>Confirm password:</th>
                <td><input type="password" name="confirm_password"></td>
            </tr>
            <tr>
                <td colspan="2"><div align="center"><input type="submit" value="Submit" /></div></td>
            </tr>
        </table>

    </form>

</div>