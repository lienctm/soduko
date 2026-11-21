
const puzzles = {

    easy: [
        [7, 4, 1, 8, 2, 5, 0, 9, 0],
        [0, 0, 5, 0, 3, 9, 0, 0, 7],
        [2, 0, 9, 6, 7, 0, 8, 0, 1],
        [0, 1, 2, 9, 0, 0, 6, 8, 0],
        [3, 6, 8, 4, 1, 0, 0, 0, 0],
        [0, 0, 7, 3, 0, 8, 1, 0, 0],
        [5, 2, 3, 7, 9, 6, 4, 0, 0],
        [0, 7, 6, 2, 4, 1, 9, 3, 5],
        [1, 9, 0, 5, 8, 3, 0, 6, 0]
    ],

    medium: [
        [0, 9, 0, 1, 3, 2, 7, 6, 5],
        [7, 1, 5, 0, 4, 6, 0, 3, 2],
        [0, 2, 3, 5, 0, 0, 4, 1, 0],
        [0, 0, 0, 0, 9, 3, 0, 4, 0],
        [0, 7, 9, 0, 0, 0, 0, 0, 6],
        [4, 6, 1, 0, 8, 5, 0, 9, 3],
        [0, 5, 0, 0, 0, 0, 0, 2, 9],
        [2, 0, 0, 0, 5, 0, 0, 7, 1],
        [0, 0, 0, 0, 1, 0, 0, 0, 4]
    ],

    hard: [
        [2, 1, 0, 0, 8, 0, 0, 4, 0],
        [5, 4, 0, 0, 9, 0, 0, 0, 8],
        [7, 6, 8, 0, 0, 5, 0, 2, 0],
        [0, 7, 0, 0, 5, 0, 0, 0, 1],
        [8, 3, 0, 0, 0, 0, 0, 0, 7],
        [0, 9, 5, 0, 4, 7, 2, 3, 0],
        [0, 0, 0, 5, 0, 0, 0, 6, 2],
        [0, 5, 7, 0, 6, 3, 0, 1, 4],
        [0, 0, 6, 0, 0, 0, 0, 0, 0]
    ]

};


const board = document.querySelector("#board");
const status = document.querySelector("#status");

let currentPuzzle = null;
let currentLevel = null;
let currentPlayer = "";
let playerScore = 0;

const completedLevels = new Set();

const players = [
    { name: "Kim", score: 15 },
    { name: "Adam", score: 50 },
    { name: "Chris", score: 20 },
    { name: "Bob", score: 25 },
    { name: "Chito", score: 65 },
    { name: "Milalo", score: 30 },
    { name: "Bitsu", score: 10 },
    { name: "Kitty", score: 10 },
];

function points_for_level(level) {
    if (level === "easy") return 5;
    if (level === "medium") return 10;
    if (level === "hard") return 15;

    return 0;
}

function updateRank() {
    const rankList = document.querySelector("#rankList");
    const playerRank = document.querySelector("#playerRank");

    const ranked = [...players].sort(
        (a, b) => b.score - a.score
    );
    const topPlayers = ranked.slice(0, 5);

    rankList.replaceChildren();
    topPlayers.forEach(
        (player, index) => {
            const line = document.createElement("p");

            line.textContent =
                `${index + 1}. ${player.name}    ${player.score} pts`;

            rankList.append(line);
        }
    );

    const rank = ranked.findIndex(player => player.name === currentPlayer) + 1;
    playerRank.textContent =
        `\n${currentPlayer}   ${playerScore} pts`;
}

function updatePlayerScore(score) {
    playerScore = score;

    const existingPlayer = players.find(
        player => player.name === currentPlayer
    );

    if (existingPlayer) {
        existingPlayer.score = score;
    } else {
        players.push({ name: currentPlayer, score: score });
    }

    updateRank();
}

function buildBoard() {
    board.replaceChildren();

    for (let i = 0; i < 81; i++) {
        const cell = document.createElement("input");

        cell.type = "text";
        cell.inputMode = "numeric";
        cell.maxLength = 1;

        cell.addEventListener("input", () => {
            cell.value = cell.value
                .replace(/[^1-9]/g, "")
                .slice(0, 1);

            cell.classList.add("user");
        });

        board.append(cell);
    }
}


function loadLevel(level) {
    currentLevel = level;
    currentPuzzle = puzzles[level];

    [...board.children].forEach((cell, i) => {
        const row = Math.floor(i / 9);
        const col = i % 9;
        const value = currentPuzzle[row][col];

        cell.value = value || "";
        cell.className = value ? "given" : "";
    });

    document
        .querySelectorAll("[game-level]")
        .forEach(button => {
            button.classList.toggle(
                "active",
                button.getAttribute("game-level") === level
            );
        });

    status.textContent =
        `Playing ${level}. Fill in the empty cells.`;

    status.className = "";
}


function readGrid() {
    return [...board.children].reduce((rows, cell, i) => {
        if (i % 9 === 0) {
            rows.push([]);
        }

        rows.at(-1).push(Number(cell.value) || 0);

        return rows;
    }, []);
}


async function getSolution() {
    const response = await fetch("/solve", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            grid: readGrid()
        })
    });

    const data = await response.json();

    if (!response.ok || data.status !== "success") {
        throw new Error("There is a conflict in your answers.");
    }

    return data.grid;
}


document
    .querySelector("#submitName")
    .addEventListener("click", () => {

        const name =
            document.querySelector("#nickname").value.trim();

        if (!name) {
            document.querySelector("#welcomeError").textContent =
                "Please enter a nickname.";
            return;
        }

        document.querySelector("#playerName").textContent = name;
        currentPlayer = name;
        const existingPlayer = players.find(
            player => player.name === currentPlayer
        );
        playerScore = existingPlayer ? existingPlayer.score : 0;
        updatePlayerScore(playerScore);

        document.querySelector("#welcome")
            .classList.add("hidden");

        document.querySelector("#game")
            .classList.remove("hidden");

        buildBoard();
    });


document
    .querySelector("#nickname")
    .addEventListener("keydown", event => {
        if (event.key === "Enter") {
            document.querySelector("#submitName").click();
        }
    });


document
    .querySelectorAll("[game-level]")
    .forEach(button => {
        button.addEventListener("click", () => {
            loadLevel(button.getAttribute("game-level"));
        });
    });


document
    .querySelector("#check")
    .addEventListener("click", async () => {

        if (!currentPuzzle) {
            status.textContent = "Choose a level first.";
            return;
        }

        try {
            const solution = await getSolution();
            const grid = readGrid();

            const complete = grid.every((row, r) =>
                row.every((value, c) => value === solution[r][c])
            );

            if (complete) {
                if (!completedLevels.has(currentLevel)) {
                    const points = points_for_level(currentLevel);

                    completedLevels.add(currentLevel);

                    updatePlayerScore(playerScore + points);

                    status.textContent =
                        `Correct! You earned ${points} points.`;

                    status.className = "success";
                }
            } else {
                status.textContent =
                    "So far so good, but keep going!";
                status.className = "";
            }

        } catch (error) {
            status.textContent = error.message;
            status.className = "error";
        }
    });


document
    .querySelector("#reveal")
    .addEventListener("click", async () => {

        if (!currentPuzzle) {
            return;
        }

        try {
            const solution = await getSolution();

            [...board.children].forEach((cell, i) => {
                const row = Math.floor(i / 9);
                const col = i % 9;

                cell.value = solution[row][col];
                cell.classList.add("user");
            });

            status.textContent = "Solution revealed.";

        } catch (error) {
            status.textContent = error.message;
            status.className = "error";
        }
    });


document
    .querySelector("#clear")
    .addEventListener("click", () => {
        if (currentLevel) {
            loadLevel(currentLevel);
        }
    });


document
    .querySelector("#logout")
    .addEventListener("click", () => {
        document.querySelector("#nickname").value = "";
        document.querySelector("#welcomeError").textContent = "";
        document.querySelector("#playerName").textContent = "";
        document.querySelector("#rankList").replaceChildren();
        document.querySelector("#playerRank").textContent = "";
        board.replaceChildren();
        status.textContent = "";
        status.className = "";

        currentPlayer = "";
        playerScore = 0;
        currentPuzzle = null;
        currentLevel = null;

        document.querySelector("#game")
            .classList.add("hidden");

        document.querySelector("#welcome")
            .classList.remove("hidden");
    });
