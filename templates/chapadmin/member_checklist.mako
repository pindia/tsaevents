<html lang="en">
<head>
    <title>TSA Events - Member Checklist</title>
    <link rel="stylesheet" href="/static/tsa/style.css" type="text/css">
</head>
<body>
    <table class="layout">
    <tr>
        <td style="vertical-align: top;">
            <h3>${chapter.name}</h3>
            <table class="tabular_list">
                % for member in members.filter(profile__is_member=True).order_by('last_name'):
                <tr>
                    <th><input type="checkbox"></th>
                    <td style="text-align:left;">${member.first_name} ${member.last_name}</td>
                </tr>
                % endfor
            </table>
        </td>
        <td style="vertical-align: top;">
            % if chapter.link or chapter.reverselink:
                <% c = chapter.link or chapter.reverselink %>
                <h3>${c.name}</h3>
                <table class="tabular_list">
                    % for prof in c.members.filter(is_member=True).order_by('user__last_name'):
                    <tr>
                        <th><input type="checkbox"></th>
                        <td style="text-align:left;">${prof.user.first_name} ${prof.user.last_name}</td>
                    </tr>
                    % endfor
                </table>
            % endif
        </td>
    </tr>
    </table>
</body>
</html>
