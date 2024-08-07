const outputDiv = document.getElementById('output');
const commandInput = document.getElementById('commandInput');

const commands = {
    help: `Available commands:
- add: Adds a player record.
- lookup: Looks up player records by name.
- delete: Deletes a player record (requires password).
- clear: Clears the screen.
- help: Shows this help message.`,

    clear: () => {
        outputDiv.innerHTML = '';
    },

    add: async (params) => {
        const { player_name, fivem_license, warn_ban, conduct_id, reason } = params;
        const response = await fetch('/api/record', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ player_name, fivem_license, warn_ban, conduct_id, reason }),
        });
        const result = await response.text();
        outputDiv.innerText += result + '\n';
    },

    lookup: async (params) => {
        const response = await fetch(`/api/record?player_name=${params.player_name}`);
        const results = await response.json();
        if (results.length > 0) {
            results.forEach(record => {
                outputDiv.innerText += JSON.stringify(record, null, 2) + '\n';
            });
        } else {
            outputDiv.innerText += 'No records found.\n';
        }
    },

    delete: async (params) => {
        const { conduct_id, password } = params;
        const response = await fetch('/api/record', {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ conduct_id, password }),
        });
        const result = await response.text();
        outputDiv.innerText += result + '\n';
    }
};

commandInput.addEventListener('keydown', async (event) => {
    if (event.key === 'Enter') {
        const command = commandInput.value.trim().split(' ');
        commandInput.value = ''; // Clear input
        const cmd = command[0];
        const params = command.slice(1).reduce((acc, param) => {
            const [key, value] = param.split('=');
            acc[key] = value;
            return acc;
        }, {});

        if (cmd in commands) {
            await commands[cmd](params);
        } else {
            outputDiv.innerText += `Unknown command: ${cmd}\n`;
        }
    }
});
