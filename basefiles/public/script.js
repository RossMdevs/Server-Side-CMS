document.addEventListener('DOMContentLoaded', () => {
    const input = document.getElementById('input');
    const output = document.querySelector('.output');

    // Welcome message
    output.innerHTML += '<div>Welcome to the RMENT CMS</div>';
    output.innerHTML += '<div>Type "help" for a list of commands.</div>';

    input.addEventListener('keydown', (event) => {
        if (event.key === 'Enter') {
            const command = input.value.trim();
            output.innerHTML += `<div>ENT:> ${command}</div>`;
            handleCommand(command);
            input.value = ''; // Clear the input
        }
    });

    function handleCommand(command) {
        console.log('Command received:', command); // Debugging line
        if (command.startsWith('add')) {
            const [_, player_name, fivem_license, warn_ban, conduct_id, ...reasonParts] = command.split(' ');
            const reason = reasonParts.join(' ');
            fetch('/api/record', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ player_name, fivem_license, warn_ban, conduct_id, reason }),
            })
                .then(response => response.text())
                .then(data => {
                    output.innerHTML += `<div>${data}</div>`;
                })
                .catch(error => {
                    output.innerHTML += `<div>Error adding record: ${error}</div>`;
                });
        } else if (command.startsWith('lookup')) {
            const playerName = command.split(' ')[1]; // Get the player name from the command
            fetch(`/api/record?player_name=${playerName}`)
                .then(response => response.json())
                .then(data => {
                    if (data.length > 0) {
                        output.innerHTML += `<div>Records for ${playerName}: ${JSON.stringify(data, null, 2)}</div>`;
                    } else {
                        output.innerHTML += `<div>No records found for ${playerName}.</div>`;
                    }
                })
                .catch(error => {
                    output.innerHTML += `<div>Error fetching records: ${error}</div>`;
                });
        } else if (command.startsWith('delete')) {
            const [_, conduct_id, password] = command.split(' ');
            fetch('/api/record', {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ conduct_id, password }),
            })
                .then(response => response.text())
                .then(data => {
                    output.innerHTML += `<div>${data}</div>`;
                })
                .catch(error => {
                    output.innerHTML += `<div>Error deleting record: ${error}</div>`;
                });
        } else if (command === 'clear') {
            clearOutput();
        } else if (command === 'help') {
            output.innerHTML += helpText();
        } else {
            output.innerHTML += `<div>Unknown command: ${command}</div>`;
        }
    }

    function helpText() {
        return `
            <div><strong>Available Commands:</strong></div>
            <div><strong>add:</strong> Add a player record. Usage: <code>add &lt;player_name&gt; &lt;fivem_license&gt; &lt;Warn|Ban&gt; &lt;conduct_id&gt; &lt;reason&gt;</code></div>
            <div><strong>lookup:</strong> Retrieve player records. Usage: <code>lookup &lt;player_name&gt;</code> (partial matches are allowed).</div>
            <div><strong>delete:</strong> Delete a player record. Usage: <code>delete &lt;conduct_id&gt; &lt;password&gt;</code></div>
            <div><strong>clear:</strong> Clear the terminal screen. Usage: <code>clear</code></div>
            <div><strong>help:</strong> Display this help message. Usage: <code>help</code></div>
            <div><strong>Notes:</strong></div>
            <div>1. Player Name: The name of the player you want to add or look up.</div>
            <div>2. FiveM License: The license associated with the player.</div>
            <div>3. Warn/Ban: Specify whether to issue a warning or a ban (e.g., "Warn" or "Ban").</div>
            <div>4. Conduct ID: An identifier for the conduct record.</div>
            <div>5. Reason: A brief explanation for the warning or ban.</div>
        `;
    }

    // Function to clear the output
    function clearOutput() {
        output.innerHTML = ''; // Clear the terminal output
    }
});
