const BODY_PARTS = ['Záda', 'Prsa', 'Ruce', 'Ramena', 'Nohy', 'Břicho'];
const STORAGE_KEY = 'gymplanner-data';

function createId() {
  return crypto.randomUUID();
}

function loadData() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { exercises: [], workouts: [] };
    return JSON.parse(raw);
  } catch {
    return { exercises: [], workouts: [] };
  }
}

function saveData(data) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
}

function getExercises() {
  return loadData().exercises;
}

function getExercise(id) {
  return getExercises().find((e) => e.id === id) || null;
}

function saveExercise(exercise) {
  const data = loadData();
  const index = data.exercises.findIndex((e) => e.id === exercise.id);
  if (index >= 0) {
    data.exercises[index] = exercise;
  } else {
    data.exercises.push(exercise);
  }
  saveData(data);
}

function deleteExercise(id) {
  const data = loadData();
  data.exercises = data.exercises.filter((e) => e.id !== id);
  saveData(data);
}

function getWorkouts(completed = null) {
  const workouts = loadData().workouts;
  if (completed === null) return workouts;
  return workouts.filter((w) => w.isCompleted === completed);
}

function getWorkout(id) {
  return getWorkouts().find((w) => w.id === id) || null;
}

function saveWorkout(workout) {
  const data = loadData();
  const index = data.workouts.findIndex((w) => w.id === workout.id);
  if (index >= 0) {
    data.workouts[index] = workout;
  } else {
    data.workouts.push(workout);
  }
  saveData(data);
}

function deleteWorkout(id) {
  const data = loadData();
  data.workouts = data.workouts.filter((w) => w.id !== id);
  saveData(data);
}

function updateExerciseRecords(exerciseId, weight, reps) {
  const exercise = getExercise(exerciseId);
  if (!exercise) return;
  if (weight > (exercise.maxWeight || 0)) exercise.maxWeight = weight;
  if (reps > (exercise.maxReps || 0)) exercise.maxReps = reps;
  saveExercise(exercise);
}

function getLastPerformance(exerciseId, excludeWorkoutId = null) {
  const completed = getWorkouts(true)
    .sort((a, b) => new Date(b.completedAt || b.date) - new Date(a.completedAt || a.date));

  for (const workout of completed) {
    if (workout.id === excludeWorkoutId) continue;
    const entry = workout.exercises.find((e) => e.exerciseId === exerciseId);
    if (entry) {
      return {
        weight: entry.weight,
        reps: entry.reps,
        date: workout.completedAt || workout.date
      };
    }
  }
  return null;
}

function completeWorkout(workoutId) {
  const workout = getWorkout(workoutId);
  if (!workout) return;

  workout.isCompleted = true;
  workout.completedAt = new Date().toISOString();

  for (const entry of workout.exercises) {
    updateExerciseRecords(entry.exerciseId, entry.weight || 0, entry.reps || 0);
  }

  saveWorkout(workout);
}

function formatWeight(weight) {
  const n = Number(weight) || 0;
  return Number.isInteger(n) ? String(n) : n.toFixed(1);
}

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('cs-CZ', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  });
}

function formatDateShort(dateStr) {
  return new Date(dateStr).toLocaleDateString('cs-CZ', {
    day: 'numeric',
    month: 'numeric',
    year: 'numeric'
  });
}
