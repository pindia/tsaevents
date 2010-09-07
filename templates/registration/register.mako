<%inherit file="../layout.mako" />

<%def name="title()">Create Account</%def>
<%def name="bigtitle()">${self.title()}</%def>


<div class="span-24 last" align="center">
    <h1>TSA Events - Create Account</h1>
    
    % if error_msg:
        <div class="error">${error_msg}</div>
    % endif
    
    <p>${chapter.info | h}</p>
        
    % if chapter.register_open:

    <p><i>Creating new account in the <b>${chapter.name}</b> chapter.</i></p>

    % if chapter.key:
        <p><i>Note: this chapter requires a key to create a new account. You should have received this key from a chapter advisor or officer.</i></p>
    % endif

    <form action="/accounts/create/" method='post'>
    <input type="hidden" name="chapter" value="${chapter.id}">
        
        <table class="layouttable aligner">
            ${form.as_table()}
        </table>
        
        % if fields:
            <p>The following additional information is requested by your chapter:</p>
            <table class="aligner layouttable">
            % for field in fields:
                <tr>
                    <td><b>${field.name}:</b></td>
                    <td>
                    % if field.type == 0:
                        <input type="checkbox" name="field_${field.id}" >
                    % else:
                        <input type="entry" name="field_${field.id}" >
                    % endif
                    </td>
                </tr>
            % endfor
            </table>
        
        % endif
        
        <div align="center"><input type="submit" value="Create" />

    </form>
    
    % else:
    
        <div class="error">
            Registration for this chapter has been closed by a chapter administrator. Contact your chapter advisor for assistance.
        </div>
    
    % endif

</div>


