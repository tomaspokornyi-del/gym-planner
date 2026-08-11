let currentTab = 'library';
let currentWorkoutId = null;

const titles = {
  library: 'Knihovna cviků',
  workout: 'Trénink',
  archive: 'Archiv',
  'workout-detail': 'Trénink',
  'archive-detail': 'Archivovaný trénink'
};

function init() {
  document.querySelectorAll('.tab').forEach((tab) => {
    tab.addEventListener('click', () => {
      currentWorkoutId = null;
      switchTab(tab.dataset.tab);
    });
  });

  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('./sw.js?v=3').then((reg) => {
      reg.update();
    }).catch(() => {});
  }

  render();
}

function switchTab(tab) {
  currentTab = tab;
  document.querySelectorAll('.tab').forEach((el) => {
    el.classList.toggle('active', el.dataset.tab === tab);
  });
  render();
}

function setTitle(key) {
  document.getElementById('page-title').textContent = titles[key] || titles.library;
}

function render() {
  const main = document.getElementById('main-content');

  if (currentWorkoutId && currentTab === 'workout') {
    setTitle('workout-detail');
    main.innerHTML = renderWorkoutDetail(currentWorkoutId);
    bindWorkoutDetailEvents(currentWorkoutId);
    return;
  }

  if (currentWorkoutId && currentTab === 'archive') {
    setTitle('archive-detail');
    main.innerHTML = renderArchiveDetail(currentWorkoutId);
    bindArchiveDetailEvents(currentWorkoutId);
    return;
  }

  setTitle(currentTab);

  if (currentTab === 'library') {
    main.innerHTML = renderLibrary();
    bindLibraryEvents();
  } else if (currentTab === 'workout') {
    main.innerHTML = renderWorkoutList();
    bindWorkoutListEvents();
  } else if (currentTab === 'archive') {
    main.innerHTML = renderArchive();
    bindArchiveEvents();
  }
}

function renderLibrary() {
  const exercises = getExercises().sort((a, b) => a.name.localeCompare(b.name, 'cs'));

  if (exercises.length === 0) {
    return `
      <div class="empty-state">
        <div class="empty-icon">🏋️</div>
        <p>Žádné cviky</p>
        <p class="muted">Přidejte první cvik do knihovny</p>
      </div>
      <button class="fab" id="add-exercise-btn" aria-label="Přidat cvik">+</button>
    `;
  }

  const grouped = BODY_PARTS.map((part) => ({
    part,
    items: exercises.filter((e) => e.bodyPart === part)
  })).filter((g) => g.items.length > 0);

  return `
    ${grouped.map(({ part, items }) => `
      <section class="section">
        <h2 class="section-title">${part}</h2>
        ${items.map((ex) => `
          <article class="card exercise-card" data-id="${ex.id}">
            <div class="card-main">
              <h3>${escapeHtml(ex.name)}</h3>
              <p class="meta">Rekord: ${formatWeight(ex.maxWeight || 0)} kg × ${ex.maxReps || 0}</p>
            </div>
            <button class="icon-btn delete-exercise" data-id="${ex.id}" aria-label="Smazat">🗑️</button>
          </article>
        `).join('')}
      </section>
    `).join('')}
    <button class="fab" id="add-exercise-btn" aria-label="Přidat cvik">+</button>
  `;
}

function renderWorkoutList() {
  const workouts = getWorkouts(false).sort((a, b) => new Date(b.date) - new Date(a.date));

  if (workouts.length === 0) {
    return `
      <div class="empty-state">
        <div class="empty-icon">💪</div>
        <p>Žádný trénink</p>
        <p class="muted">Vytvořte nový trénink a poskládejte si cviky</p>
      </div>
      <button class="fab" id="add-workout-btn" aria-label="Nový trénink">+</button>
    `;
  }

  return `
    ${workouts.map((w) => `
      <article class="card workout-card" data-id="${w.id}">
        <div class="card-main">
          <h3>${formatDate(w.date)}</h3>
          <p class="meta">${w.exercises.length} cviků</p>
        </div>
        <button class="icon-btn delete-workout" data-id="${w.id}" aria-label="Smazat trénink">🗑️</button>
        <span class="chevron">›</span>
      </article>
    `).join('')}
    <button class="fab" id="add-workout-btn" aria-label="Nový trénink">+</button>
  `;
}

function renderWorkoutDetail(workoutId) {
  const workout = getWorkout(workoutId);
  if (!workout) return '<p>Trénink nenalezen.</p>';

  const dateValue = workout.date.slice(0, 10);

  return `
    <button class="back-btn" id="back-btn">← Zpět</button>

    <section class="section">
      <label class="field">
        <span>Datum tréninku</span>
        <input type="date" id="workout-date" value="${dateValue}">
      </label>
    </section>

    <section class="section">
      <div class="section-header">
        <h2 class="section-title">Cviky</h2>
        <button class="text-btn" id="add-to-workout-btn">+ Přidat</button>
      </div>

      ${workout.exercises.length === 0 ? `
        <p class="muted center">Přidejte cviky z knihovny</p>
      ` : workout.exercises.map((entry, index) => {
        const exercise = getExercise(entry.exerciseId);
        if (!exercise) return '';
        const normalized = normalizeWorkoutEntry(entry);
        const last = getLastPerformance(exercise.id, workoutId);
        return `
          <article class="card workout-exercise-card">
            <div class="exercise-header">
              <h3>${escapeHtml(exercise.name)}</h3>
              <span class="badge">${exercise.bodyPart}</span>
            </div>
            ${last ? `<p class="last-perf">↩ Minule (nejlepší série): ${formatWeight(last.weight)} kg × ${last.reps}</p>` : ''}
            <div class="set-count-row">
              <label class="field set-count-field">
                <span>Počet sérií</span>
                <input type="number" min="1" max="20" step="1" inputmode="numeric"
                  class="set-count-input" data-index="${index}" value="${normalized.sets.length}">
              </label>
            </div>
            <div class="sets-list">
              ${normalized.sets.map((set, setIndex) => {
                const lastSet = last?.sets?.[setIndex];
                return `
                  <div class="set-row">
                    <div class="set-label">
                      <strong>Série ${setIndex + 1}</strong>
                      ${lastSet ? `<span class="set-last">Minule: ${formatWeight(lastSet.weight)} kg × ${lastSet.reps}</span>` : ''}
                    </div>
                    <div class="input-row">
                      <label class="field compact">
                        <span>Váha (kg)</span>
                        <input type="number" min="0" step="0.5" inputmode="decimal"
                          data-index="${index}" data-set="${setIndex}" data-field="weight"
                          value="${set.weight || ''}" placeholder="0">
                      </label>
                      <label class="field compact">
                        <span>Opakování</span>
                        <input type="number" min="0" step="1" inputmode="numeric"
                          data-index="${index}" data-set="${setIndex}" data-field="reps"
                          value="${set.reps || ''}" placeholder="0">
                      </label>
                    </div>
                  </div>
                `;
              }).join('')}
            </div>
            <button class="text-btn danger remove-exercise" data-index="${index}">Odebrat cvik</button>
          </article>
        `;
      }).join('')}
    </section>

    <section class="section workout-actions">
      ${workout.exercises.length > 0 ? `
        <button class="primary-btn" id="complete-workout-btn">✓ Dokončit trénink</button>
      ` : ''}
      <button class="danger-btn" id="delete-workout-btn">Smazat trénink</button>
    </section>
  `;
}

function renderArchive() {
  const workouts = getWorkouts(true).sort(
    (a, b) => new Date(b.completedAt || b.date) - new Date(a.completedAt || a.date)
  );

  if (workouts.length === 0) {
    return `
      <div class="empty-state">
        <div class="empty-icon">📦</div>
        <p>Archiv je prázdný</p>
        <p class="muted">Dokončené tréninky se zobrazí zde</p>
      </div>
    `;
  }

  return workouts.map((w) => `
    <article class="card workout-card" data-id="${w.id}">
      <div class="card-main">
        <h3>${formatDate(w.date)}</h3>
        <p class="meta">${w.exercises.length} cviků · Dokončeno ${formatDateShort(w.completedAt || w.date)}</p>
      </div>
      <span class="chevron">›</span>
    </article>
  `).join('');
}

function renderArchiveDetail(workoutId) {
  const workout = getWorkout(workoutId);
  if (!workout) return '<p>Trénink nenalezen.</p>';

  return `
    <button class="back-btn" id="back-btn">← Zpět</button>

    <section class="section">
      <div class="info-row"><span>Datum tréninku</span><strong>${formatDate(workout.date)}</strong></div>
      ${workout.completedAt ? `
        <div class="info-row"><span>Dokončeno</span><strong>${formatDate(workout.completedAt)}</strong></div>
      ` : ''}
    </section>

    <section class="section">
      <h2 class="section-title">Cviky</h2>
      ${workout.exercises.map((entry) => {
        const exercise = getExercise(entry.exerciseId);
        if (!exercise) return '';
        const normalized = normalizeWorkoutEntry(entry);
        return `
          <article class="card">
            <div class="exercise-header">
              <div>
                <h3>${escapeHtml(exercise.name)}</h3>
                <p class="meta">${exercise.bodyPart} · ${normalized.sets.length} série</p>
              </div>
            </div>
            <div class="archive-sets">
              ${normalized.sets.map((set, i) => `
                <div class="archive-set-row">
                  <span class="archive-set-label">Série ${i + 1}</span>
                  <strong class="result">${formatWeight(set.weight || 0)} kg × ${set.reps || 0}</strong>
                </div>
              `).join('')}
            </div>
          </article>
        `;
      }).join('')}
    </section>
  `;
}

function bindLibraryEvents() {
  document.getElementById('add-exercise-btn')?.addEventListener('click', () => showExerciseForm());
  document.querySelectorAll('.exercise-card').forEach((card) => {
    card.addEventListener('click', (e) => {
      if (e.target.closest('.delete-exercise')) return;
      showExerciseForm(card.dataset.id);
    });
  });
  document.querySelectorAll('.delete-exercise').forEach((btn) => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      if (confirm('Smazat tento cvik?')) {
        deleteExercise(btn.dataset.id);
        render();
      }
    });
  });
}

function deleteWorkoutWithConfirm(workoutId, onDeleted) {
  if (!confirm('Opravdu smazat tento trénink? Tuto akci nelze vrátit.')) return;
  deleteWorkout(workoutId);
  onDeleted();
}

function bindWorkoutListEvents() {
  document.getElementById('add-workout-btn')?.addEventListener('click', showNewWorkoutForm);
  document.querySelectorAll('.workout-card').forEach((card) => {
    card.addEventListener('click', (e) => {
      if (e.target.closest('.delete-workout')) return;
      currentWorkoutId = card.dataset.id;
      render();
    });
  });
  document.querySelectorAll('.delete-workout').forEach((btn) => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      deleteWorkoutWithConfirm(btn.dataset.id, () => {
        if (currentWorkoutId === btn.dataset.id) currentWorkoutId = null;
        render();
      });
    });
  });
}

function bindWorkoutDetailEvents(workoutId) {
  document.getElementById('back-btn')?.addEventListener('click', () => {
    currentWorkoutId = null;
    render();
  });

  document.getElementById('workout-date')?.addEventListener('change', (e) => {
    const workout = getWorkout(workoutId);
    workout.date = new Date(e.target.value).toISOString();
    saveWorkout(workout);
  });

  document.getElementById('add-to-workout-btn')?.addEventListener('click', () => {
    showAddExerciseToWorkout(workoutId);
  });

  document.querySelectorAll('.set-count-input').forEach((input) => {
    input.addEventListener('change', () => {
      const workout = getWorkout(workoutId);
      const index = Number(input.dataset.index);
      const count = parseInt(input.value, 10) || 1;
      workout.exercises[index] = ensureSetCount(workout.exercises[index], count);
      saveWorkout(workout);
      render();
    });
  });

  document.querySelectorAll('[data-field][data-set]').forEach((input) => {
    input.addEventListener('change', () => {
      const workout = getWorkout(workoutId);
      const index = Number(input.dataset.index);
      const setIndex = Number(input.dataset.set);
      const field = input.dataset.field;
      const entry = normalizeWorkoutEntry(workout.exercises[index]);
      entry.sets[setIndex][field] = field === 'weight'
        ? parseFloat(input.value) || 0
        : parseInt(input.value, 10) || 0;
      workout.exercises[index] = entry;
      saveWorkout(workout);
    });
  });

  document.querySelectorAll('.remove-exercise').forEach((btn) => {
    btn.addEventListener('click', () => {
      const workout = getWorkout(workoutId);
      workout.exercises.splice(Number(btn.dataset.index), 1);
      saveWorkout(workout);
      render();
    });
  });

  document.getElementById('complete-workout-btn')?.addEventListener('click', () => {
    if (confirm('Dokončit trénink? Přesune se do archivu a aktualizují se rekordy cviků.')) {
      completeWorkout(workoutId);
      currentWorkoutId = null;
      switchTab('archive');
    }
  });

  document.getElementById('delete-workout-btn')?.addEventListener('click', () => {
    deleteWorkoutWithConfirm(workoutId, () => {
      currentWorkoutId = null;
      render();
    });
  });
}

function bindArchiveEvents() {
  document.querySelectorAll('.workout-card').forEach((card) => {
    card.addEventListener('click', () => {
      currentWorkoutId = card.dataset.id;
      render();
    });
  });
}

function bindArchiveDetailEvents() {
  document.getElementById('back-btn')?.addEventListener('click', () => {
    currentWorkoutId = null;
    render();
  });
}

function showModal(content) {
  document.getElementById('modal').innerHTML = content;
  document.getElementById('modal').classList.remove('hidden');
  document.getElementById('modal-overlay').classList.remove('hidden');
}

function hideModal() {
  document.getElementById('modal').classList.add('hidden');
  document.getElementById('modal-overlay').classList.add('hidden');
}

function bindModalClose() {
  document.getElementById('modal-overlay').onclick = hideModal;
  document.querySelectorAll('[data-close]').forEach((el) => {
    el.addEventListener('click', hideModal);
  });
}

function showExerciseForm(exerciseId = null) {
  const exercise = exerciseId
    ? getExercise(exerciseId)
    : { id: createId(), name: '', bodyPart: 'Prsa', maxWeight: 0, maxReps: 0 };

  showModal(`
    <div class="modal-content">
      <h2>${exerciseId ? 'Upravit cvik' : 'Nový cvik'}</h2>
      <label class="field">
        <span>Název cviku</span>
        <input type="text" id="exercise-name" value="${escapeHtml(exercise.name)}" placeholder="např. Bench press">
      </label>
      <label class="field">
        <span>Partie</span>
        <select id="exercise-part">
          ${BODY_PARTS.map((p) => `
            <option value="${p}" ${exercise.bodyPart === p ? 'selected' : ''}>${p}</option>
          `).join('')}
        </select>
      </label>
      ${exerciseId ? `
        <div class="records">
          <div class="info-row"><span>Nejvyšší váha</span><strong>${formatWeight(exercise.maxWeight || 0)} kg</strong></div>
          <div class="info-row"><span>Nejvíce opakování</span><strong>${exercise.maxReps || 0}×</strong></div>
        </div>
      ` : ''}
      <div class="modal-actions">
        <button class="secondary-btn" data-close>Zrušit</button>
        <button class="primary-btn" id="save-exercise-btn">Uložit</button>
      </div>
    </div>
  `);

  bindModalClose();
  document.getElementById('save-exercise-btn').addEventListener('click', () => {
    const name = document.getElementById('exercise-name').value.trim();
    if (!name) return alert('Zadejte název cviku.');
    exercise.name = name;
    exercise.bodyPart = document.getElementById('exercise-part').value;
    saveExercise(exercise);
    hideModal();
    render();
  });
}

function showNewWorkoutForm() {
  const today = new Date().toISOString().slice(0, 10);
  showModal(`
    <div class="modal-content">
      <h2>Nový trénink</h2>
      <label class="field">
        <span>Datum tréninku</span>
        <input type="date" id="new-workout-date" value="${today}">
      </label>
      <div class="modal-actions">
        <button class="secondary-btn" data-close>Zrušit</button>
        <button class="primary-btn" id="create-workout-btn">Vytvořit</button>
      </div>
    </div>
  `);

  bindModalClose();
  document.getElementById('create-workout-btn').addEventListener('click', () => {
    const date = document.getElementById('new-workout-date').value;
    const workout = {
      id: createId(),
      date: new Date(date).toISOString(),
      isCompleted: false,
      completedAt: null,
      exercises: []
    };
    saveWorkout(workout);
    hideModal();
    currentWorkoutId = workout.id;
    render();
  });
}

function showAddExerciseToWorkout(workoutId) {
  const exercises = getExercises().sort((a, b) => a.name.localeCompare(b.name, 'cs'));

  if (exercises.length === 0) {
    alert('Nejdříve přidejte cviky do knihovny.');
    return;
  }

  showModal(`
    <div class="modal-content modal-tall">
      <h2>Přidat cvik</h2>
      <div class="filter-chips" id="part-filters">
        <button class="chip active" data-part="">Vše</button>
        ${BODY_PARTS.map((p) => `<button class="chip" data-part="${p}">${p}</button>`).join('')}
      </div>
      <div id="exercise-picker">
        ${renderExercisePicker(exercises, '')}
      </div>
      <button class="secondary-btn full-width" data-close>Zavřít</button>
    </div>
  `);

  bindModalClose();

  let selectedPart = '';
  document.querySelectorAll('#part-filters .chip').forEach((chip) => {
    chip.addEventListener('click', () => {
      selectedPart = chip.dataset.part;
      document.querySelectorAll('#part-filters .chip').forEach((c) => c.classList.toggle('active', c === chip));
      document.getElementById('exercise-picker').innerHTML = renderExercisePicker(exercises, selectedPart);
      bindPickerEvents(workoutId);
    });
  });

  bindPickerEvents(workoutId);
}

function renderExercisePicker(exercises, part) {
  const filtered = part ? exercises.filter((e) => e.bodyPart === part) : exercises;
  const grouped = BODY_PARTS.map((p) => ({
    part: p,
    items: filtered.filter((e) => e.bodyPart === p)
  })).filter((g) => g.items.length > 0);

  if (grouped.length === 0) return '<p class="muted center">Žádné cviky v této kategorii</p>';

  return grouped.map(({ part, items }) => `
    <section class="picker-section">
      <h3>${part}</h3>
      ${items.map((ex) => `
        <button class="picker-item" data-id="${ex.id}">
          <div>
            <strong>${escapeHtml(ex.name)}</strong>
            ${ex.maxWeight || ex.maxReps ? `<span class="meta">Rekord: ${formatWeight(ex.maxWeight || 0)} kg × ${ex.maxReps || 0}</span>` : ''}
          </div>
          <span>+</span>
        </button>
      `).join('')}
    </section>
  `).join('');
}

function bindPickerEvents(workoutId) {
  document.querySelectorAll('.picker-item').forEach((btn) => {
    btn.addEventListener('click', () => {
      const workout = getWorkout(workoutId);
      workout.exercises.push(createWorkoutEntry(btn.dataset.id, 3));
      saveWorkout(workout);
      hideModal();
      render();
    });
  });
}

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

document.addEventListener('DOMContentLoaded', init);
