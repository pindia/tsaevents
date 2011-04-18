<%inherit file="../base.mako" />

<%def name="title()">Email Chapter </%def>

<%def name="scripts()">
<style>
.email-target{
    margin: 10px;
}
.email-list{
    margin-top: 5px;
}
td{
    padding: 0;
}
</style>

<script language="javascript">
$(document).ready(function(){
   $('#field-list').hide();
   $('#specific-list').hide();
   $('input[type="radio"]').click(function(){
        $('.email-list').slideUp();
        list = $('#' + $(this).attr('id') + '-list')
        list.slideDown();
   });
});

</script>
</%def>


<form action="/email" method="post">
    Send email to:
    <div class="email-target">
        <input id="group" type="radio" name="target" value="group" checked="yes">
        <b>All members</b>
        <div id="group-list" class="email-list" style="width: 150px; text-align:left;">
            <input type="checkbox" name="groups" value="members" checked="true">Members<br>
            <input type="checkbox" name="groups" value="officers" checked="true">Officers<br>
            <input type="checkbox" name="groups" value="advisors" checked="true">Advisors
        </div>
    </div>
    <div class="email-target">
        <input id="specific" type="radio" name="target" value="specific">
        <b>Specific members</b>
        <div id="specific-list" class="email-list">
            <table>
                % for member in members:
                    <tr>
                        <td><input type="checkbox" name="members" value="${member.id}"></td>
                        <td>${member.user.first_name} ${member.user.last_name}</td>
                        <td>${member.user.email}</td>
                    </tr>
                % endfor
            </table>
        </div>
    </div>
    <div class="email-target">
        <input id="field" type="radio" name="target" value="field">
        <b>Based on field</b>
        <div id="field-list" class="email-list">
            <select name="field">
                % for field in chapter.get_fields().filter(type=0):
                    <option value="${field.id}">${field.name}</option>
                % endfor
            </select>
            Equals
            <select name="value">
                <option value="0">No</option>
                <option value="1">Yes</option>
            </select>
        </div>
    </div>
    
    <div>
        <b>From:</b> ${user.first_name} ${user.last_name} &lt;${user.email}&gt;<br>
        <b>Subject:</b> <input type="entry" name="subject"><br>
        <b>Body:</b> <textarea name="body"></textarea><br>
        <input type="submit" value="Send">
    </div>

</form>

