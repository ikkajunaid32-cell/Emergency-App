// ==============================================================
// DAILY TASKS - ENTERPRISE WEB ADMIN DASHBOARD LOGIC
// Connected to Central Relational SQL Database (node:sqlite)
// ==============================================================

const API_BASE = window.location.origin.includes('5000') 
  ? '/api' 
  : 'http://localhost:5000/api';

// Reactive Collections (Synchronized with SQL database)
let tasks = [
  {
    id: 'task_1',
    title: 'Morning Park & Trail Cleanup',
    category: 'Eco & Green',
    pointsReward: 250,
    description: 'Collect at least one bag of litter from your local neighborhood park or hiking trail.',
    detailedInstructions: '1. Grab a recyclable trash bag and gloves.\n2. Spend 20-30 minutes collecting litter along trails, picnic areas, or sports fields.\n3. Take a photo of the filled bag disposed in a public bin.\n4. Enable GPS verification to confirm you completed the task at a park.',
    bannerUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
    deadline: '24 Hours',
    requiredSubmissions: ['text', 'photo', 'location'],
    status: 'active',
  },
  {
    id: 'task_2',
    title: '5,000 Morning Steps Challenge',
    category: 'Fitness & Health',
    pointsReward: 150,
    description: 'Complete a brisk morning walk of 5,000+ steps to energize your day.',
    detailedInstructions: '1. Put on your running shoes and track your walk on your fitness tracker.\n2. Take a screenshot of your step count exceeding 5,000 steps.\n3. Write a short note describing your route.',
    bannerUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
    deadline: '12 Hours',
    requiredSubmissions: ['text', 'photo'],
    status: 'active',
  },
  {
    id: 'task_3',
    title: 'Support a Local Coffee Shop',
    category: 'Community',
    pointsReward: 180,
    description: 'Order from a neighborhood small business coffee shop and leave a thoughtful review.',
    detailedInstructions: '1. Visit an independent local coffee shop.\n2. Snap a photo of your cup with the storefront.\n3. Verify your location at the venue.',
    bannerUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800',
    deadline: '18 Hours',
    requiredSubmissions: ['text', 'photo', 'location'],
    status: 'active',
  }
];

let submissions = [
  {
    id: 'sub_1',
    taskId: 'task_2',
    taskTitle: '5,000 Morning Steps Challenge',
    pointsReward: 150,
    userName: 'Alex Johnson',
    userEmail: 'alex@example.com',
    submittedAt: '45 mins ago',
    status: 'pending',
    textResponse: 'Walked through the botanical garden loop early this morning. Total 6,240 steps recorded on my Fitbit!',
    photoUrls: ['https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800'],
    locationAddress: 'Botanical Gardens Loop, Brisbane',
  },
  {
    id: 'sub_2',
    taskId: 'task_1',
    taskTitle: 'Morning Park & Trail Cleanup',
    pointsReward: 250,
    userName: 'Sarah Miller',
    userEmail: 'sarah@example.com',
    submittedAt: '3 hours ago',
    status: 'approved',
    textResponse: 'Cleaned up plastic bottles and snack wrappers near the children playground.',
    photoUrls: ['https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800'],
    locationAddress: 'Victoria Park, Central Lawn, Brisbane',
  },
  {
    id: 'sub_3',
    taskId: 'task_3',
    taskTitle: 'Support a Local Coffee Shop',
    pointsReward: 180,
    userName: 'Jordan Lee',
    userEmail: 'citizen@eatclubtasks.com',
    submittedAt: '15 mins ago',
    status: 'pending',
    textResponse: 'Tried the flat white at Bean & Leaf. Left a 5-star Google review praising the barista!',
    photoUrls: ['https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800'],
    locationAddress: 'Bean & Leaf Roasters, 42 Main St',
  }
];

let rewards = [
  {
    id: 'rew_1',
    title: '$10 Artisan Coffee Voucher',
    category: 'Dining & Drinks',
    pointsCost: 350,
    stock: 25,
    imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600',
  },
  {
    id: 'rew_2',
    title: '1-Day Premium Fitness Pass',
    category: 'Health & Fitness',
    pointsCost: 500,
    stock: 12,
    imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600',
  },
  {
    id: 'rew_3',
    title: '$25 Amazon Gift Card',
    category: 'Shopping',
    pointsCost: 900,
    stock: 8,
    imageUrl: 'https://images.unsplash.com/photo-1526178613552-2b45c6c302f0?w=600',
  }
];

let users = [
  { name: 'Jordan Lee', email: 'citizen@eatclubtasks.com', phone: '0412 345 678', role: 'user', points: 420, joined: 'Sep 14, 2026' },
  { name: 'Alex Johnson', email: 'alex@example.com', phone: '0423 888 111', role: 'user', points: 650, joined: 'Sep 18, 2026' },
  { name: 'Sarah Miller', email: 'sarah@example.com', phone: '0434 999 222', role: 'user', points: 820, joined: 'Sep 10, 2026' },
];

let currentInspectingSubId = null;

// ==============================================================
// INITIALIZATION & SQL DATABASE SYNC
// ==============================================================
document.addEventListener('DOMContentLoaded', () => {
  renderDashboard();
  renderTasks();
  renderSubmissions();
  renderRewards();
  renderUsers();

  // Load live data from SQL Database Backend
  syncWithSqlBackend();
});

async function syncWithSqlBackend() {
  try {
    const health = await fetch(`${API_BASE}/health`).then(r => r.json());
    if (health.status === 'online') {
      console.log('✅ Connected to SQLite database backend:', health);

      // 1. Fetch Tasks
      const tasksRes = await fetch(`${API_BASE}/tasks`).then(r => r.json());
      if (tasksRes.tasks && tasksRes.tasks.length > 0) {
        tasks = tasksRes.tasks.map(t => ({
          id: t.id,
          title: t.title,
          description: t.description,
          detailedInstructions: t.detailed_instructions,
          bannerUrl: t.banner_url,
          category: t.category,
          pointsReward: t.points_reward,
          deadline: t.deadline,
          requiredSubmissions: t.required_submissions,
          status: t.status,
        }));
        renderTasks();
      }

      // 2. Fetch Submissions
      const subsRes = await fetch(`${API_BASE}/submissions`).then(r => r.json());
      if (subsRes.submissions) {
        submissions = subsRes.submissions.map(s => ({
          id: s.id,
          taskId: s.task_id,
          taskTitle: s.task_title,
          pointsReward: s.points_reward,
          userName: s.user_name,
          userEmail: s.user_email,
          submittedAt: s.submitted_at ? new Date(s.submitted_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : 'Recently',
          status: s.status,
          textResponse: s.text_response,
          photoUrls: s.photo_urls || [],
          locationAddress: s.location_address,
          rejectionReason: s.rejection_reason,
        }));
        renderSubmissions();
      }

      // 3. Fetch Rewards
      const rewRes = await fetch(`${API_BASE}/rewards`).then(r => r.json());
      if (rewRes.rewards && rewRes.rewards.length > 0) {
        rewards = rewRes.rewards.map(r => ({
          id: r.id,
          title: r.title,
          category: r.category,
          pointsCost: r.points_cost,
          stock: r.stock,
          imageUrl: r.image_url,
        }));
        renderRewards();
      }

      // 4. Fetch Users
      const usersRes = await fetch(`${API_BASE}/auth/users`).then(r => r.json());
      if (usersRes.users && usersRes.users.length > 0) {
        users = usersRes.users.map(u => ({
          name: u.name,
          email: u.email,
          phone: u.phone,
          role: u.role,
          points: u.points,
          joined: u.created_at ? new Date(u.created_at).toLocaleDateString() : 'Active',
        }));
        renderUsers();
      }

      renderDashboard();
    }
  } catch (err) {
    console.log('Central SQL backend currently offline. Operating in interactive standalone mode:', err);
  }
}

// ==============================================================
// TAB NAVIGATION
// ==============================================================
function switchTab(tabId) {
  const sections = ['dashboard', 'tasks', 'submissions', 'rewards', 'users', 'notifications'];
  sections.forEach(s => {
    const el = document.getElementById(`section-${s}`);
    const nav = document.getElementById(`nav-${s}`);
    if (el) el.classList.add('hidden');
    if (nav) {
      nav.className = 'nav-item flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-medium text-sm text-slate-400 hover:text-white hover:bg-slate-800 transition-all';
    }
  });

  const activeSection = document.getElementById(`section-${tabId}`);
  const activeNav = document.getElementById(`nav-${tabId}`);
  if (activeSection) activeSection.classList.remove('hidden');
  if (activeNav) {
    activeNav.className = 'nav-item flex items-center gap-3 px-3.5 py-2.5 rounded-xl font-medium text-sm transition-all bg-brand-500 text-white shadow-md shadow-brand-500/20';
  }

  const titles = {
    dashboard: 'Dashboard Overview',
    tasks: 'Task Studio',
    submissions: 'Submissions Review Queue',
    rewards: 'Rewards Store Management',
    users: 'Registered Users Directory',
    notifications: 'Notification Center'
  };
  document.getElementById('top-header-title').innerText = titles[tabId] || 'Admin Console';
}

// ==============================================================
// RENDER METHODS
// ==============================================================
function renderDashboard() {
  const activeCount = tasks.filter(t => t.status === 'active').length;
  const pendingCount = submissions.filter(s => s.status === 'pending').length;
  const completedCount = submissions.filter(s => s.status === 'approved').length;
  const pointsAwarded = submissions.filter(s => s.status === 'approved').reduce((sum, s) => sum + s.pointsReward, 0);

  document.getElementById('stat-active-tasks').innerText = activeCount;
  document.getElementById('stat-pending-subs').innerText = pendingCount;
  document.getElementById('stat-completed-tasks').innerText = completedCount;
  document.getElementById('stat-points-awarded').innerText = pointsAwarded;

  document.getElementById('badge-active-tasks').innerText = activeCount;
  document.getElementById('badge-pending-subs').innerText = pendingCount;

  // Recent Submissions Table
  const tbody = document.getElementById('dashboard-recent-subs-tbody');
  tbody.innerHTML = '';

  const pendingList = submissions.filter(s => s.status === 'pending');
  if (pendingList.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" class="py-8 text-center text-slate-400 font-medium">No pending submissions awaiting review.</td></tr>`;
    return;
  }

  pendingList.forEach(sub => {
    const tr = document.createElement('tr');
    tr.className = 'hover:bg-slate-50 transition-colors';
    tr.innerHTML = `
      <td class="py-4 px-6 font-semibold text-slate-900">${sub.taskTitle}</td>
      <td class="py-4 px-6 text-slate-600">${sub.userName} <span class="text-xs text-slate-400 block">${sub.userEmail}</span></td>
      <td class="py-4 px-6 font-bold text-brand-600">+${sub.pointsReward} PTS</td>
      <td class="py-4 px-6 text-xs text-slate-500">
        ${sub.photoUrls.length ? `<span class="bg-slate-100 text-slate-700 px-2 py-1 rounded-md font-semibold mr-1">📷 ${sub.photoUrls.length} Photo(s)</span>` : ''}
        ${sub.locationAddress ? `<span class="bg-emerald-50 text-emerald-700 px-2 py-1 rounded-md font-semibold">📍 GPS</span>` : ''}
      </td>
      <td class="py-4 px-6 text-right">
        <button onclick="inspectSubmission('${sub.id}')" class="bg-brand-500 hover:bg-brand-600 text-white text-xs font-bold px-3 py-1.5 rounded-lg shadow-sm">
          Inspect Evidence
        </button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function renderTasks() {
  const grid = document.getElementById('tasks-grid');
  grid.innerHTML = '';

  tasks.forEach(task => {
    const card = document.createElement('div');
    card.className = 'bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm hover:shadow-md transition-shadow flex flex-col justify-between';
    card.innerHTML = `
      <div>
        <div class="relative h-44 overflow-hidden">
          <img src="${task.bannerUrl}" class="w-full h-full object-cover" alt="Task banner">
          <div class="absolute top-3 left-3 bg-black/60 backdrop-blur-md text-white text-[10px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-lg">
            ${task.category}
          </div>
          <div class="absolute top-3 right-3 bg-gradient-to-r from-orange-500 to-amber-500 text-white text-xs font-extrabold px-3 py-1 rounded-full shadow-lg">
            +${task.pointsReward} PTS
          </div>
        </div>
        <div class="p-5">
          <h4 class="font-display font-bold text-base text-slate-900">${task.title}</h4>
          <p class="text-xs text-slate-500 mt-1 line-clamp-2">${task.description}</p>
          <div class="mt-4 flex flex-wrap gap-1.5">
            ${task.requiredSubmissions.map(r => `<span class="bg-slate-100 text-slate-600 text-[10px] font-bold px-2 py-0.5 rounded-md uppercase">${r}</span>`).join('')}
          </div>
        </div>
      </div>
      <div class="p-4 bg-slate-50 border-t border-slate-100 flex items-center justify-between text-xs">
        <span class="text-slate-400 font-medium"><i class="fa-regular fa-clock mr-1"></i> Expires in ${task.deadline}</span>
        <button onclick="deleteTask('${task.id}')" class="text-red-500 hover:text-red-700 font-bold"><i class="fa-solid fa-trash"></i></button>
      </div>
    `;
    grid.appendChild(card);
  });
}

function renderSubmissions(filter = 'all') {
  const container = document.getElementById('submissions-list');
  container.innerHTML = '';

  let list = submissions;
  if (filter !== 'all') {
    list = submissions.filter(s => s.status === filter);
  }

  if (list.length === 0) {
    container.innerHTML = `<div class="p-8 text-center text-slate-400 font-medium bg-white rounded-2xl border border-slate-200">No submissions in this category.</div>`;
    return;
  }

  list.forEach(sub => {
    const card = document.createElement('div');
    card.className = 'bg-white p-5 rounded-2xl border border-slate-200 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4';

    let badgeClass = 'bg-amber-50 text-amber-600 border border-amber-200';
    let statusLabel = 'PENDING REVIEW';
    if (sub.status === 'approved') {
      badgeClass = 'bg-emerald-50 text-emerald-600 border border-emerald-200';
      statusLabel = 'APPROVED';
    } else if (sub.status === 'rejected') {
      badgeClass = 'bg-red-50 text-red-600 border border-red-200';
      statusLabel = 'REJECTED';
    }

    card.innerHTML = `
      <div class="flex items-start gap-4">
        <div class="w-12 h-12 rounded-xl bg-brand-50 flex items-center justify-center text-brand-600 font-black text-lg">
          ${sub.userName.charAt(0)}
        </div>
        <div>
          <div class="flex items-center gap-2">
            <h4 class="font-bold text-slate-900">${sub.taskTitle}</h4>
            <span class="px-2 py-0.5 rounded-full text-[10px] font-extrabold ${badgeClass}">${statusLabel}</span>
          </div>
          <p class="text-xs text-slate-500 mt-0.5">Submitted by <span class="font-semibold text-slate-700">${sub.userName}</span> (${sub.userEmail}) • ${sub.submittedAt}</p>
          ${sub.rejectionReason ? `<p class="text-xs text-red-500 font-semibold mt-1">Feedback: ${sub.rejectionReason}</p>` : ''}
        </div>
      </div>
      <div class="flex items-center gap-3">
        <span class="font-display font-extrabold text-brand-600 text-lg">+${sub.pointsReward} PTS</span>
        <button onclick="inspectSubmission('${sub.id}')" class="bg-slate-900 hover:bg-slate-800 text-white text-xs font-bold px-4 py-2 rounded-xl shadow-sm">
          Inspect Evidence
        </button>
      </div>
    `;
    container.appendChild(card);
  });
}

function renderRewards() {
  const grid = document.getElementById('rewards-grid');
  grid.innerHTML = '';

  rewards.forEach(r => {
    const card = document.createElement('div');
    card.className = 'bg-white rounded-2xl border border-slate-200 p-5 shadow-sm flex flex-col justify-between';
    card.innerHTML = `
      <div>
        <div class="h-32 rounded-xl overflow-hidden mb-3">
          <img src="${r.imageUrl}" class="w-full h-full object-cover">
        </div>
        <div class="flex items-center justify-between">
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">${r.category}</span>
          <span class="text-xs font-bold text-amber-500">In Stock: ${r.stock}</span>
        </div>
        <h4 class="font-bold text-slate-900 text-sm mt-1">${r.title}</h4>
      </div>
      <div class="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between">
        <span class="font-extrabold text-brand-600">${r.pointsCost} PTS</span>
        <button onclick="deleteReward('${r.id}')" class="text-red-400 hover:text-red-600 text-xs font-bold">Remove</button>
      </div>
    `;
    grid.appendChild(card);
  });
}

function renderUsers() {
  const tbody = document.getElementById('users-table-tbody');
  tbody.innerHTML = '';

  users.forEach(u => {
    const tr = document.createElement('tr');
    tr.className = 'hover:bg-slate-50 transition-colors';
    tr.innerHTML = `
      <td class="py-4 px-6 font-semibold text-slate-900">${u.name}</td>
      <td class="py-4 px-6 text-slate-600">${u.email}</td>
      <td class="py-4 px-6 text-slate-500">${u.phone}</td>
      <td class="py-4 px-6"><span class="px-2.5 py-1 rounded-full text-xs font-bold ${u.role === 'admin' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'}">${u.role.toUpperCase()}</span></td>
      <td class="py-4 px-6 font-bold text-brand-600">${u.points} PTS</td>
      <td class="py-4 px-6 text-xs text-slate-400">${u.joined}</td>
      <td class="py-4 px-6 text-right">
        <button onclick="grantBonusPoints('${u.email}')" class="text-brand-600 hover:text-brand-800 text-xs font-bold">Grant Points</button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

// ==============================================================
// TASK CREATION MODAL & ACTIONS
// ==============================================================
function openCreateTaskModal() {
  document.getElementById('modal-create-task').classList.remove('hidden');
}

function closeCreateTaskModal() {
  document.getElementById('modal-create-task').classList.add('hidden');
}

async function handleCreateTask(e) {
  e.preventDefault();

  const title = document.getElementById('task-title').value.trim();
  const category = document.getElementById('task-category').value;
  const points = parseInt(document.getElementById('task-points').value) || 100;
  const deadlineHrs = parseInt(document.getElementById('task-deadline').value) || 24;
  const desc = document.getElementById('task-desc').value.trim();
  const instructions = document.getElementById('task-instructions').value.trim();
  const bannerUrl = document.getElementById('task-banner').value.trim() || 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800';

  const reqs = [];
  if (document.getElementById('req-text').checked) reqs.push('text');
  if (document.getElementById('req-photo').checked) reqs.push('photo');
  if (document.getElementById('req-video').checked) reqs.push('video');
  if (document.getElementById('req-file').checked) reqs.push('file');
  if (document.getElementById('req-location').checked) reqs.push('location');

  const newTask = {
    id: `task_${Date.now()}`,
    title,
    category,
    pointsReward: points,
    description: desc,
    detailedInstructions: instructions,
    bannerUrl,
    deadline: `${deadlineHrs} Hours`,
    requiredSubmissions: reqs,
    status: 'active',
  };

  tasks.unshift(newTask);
  renderTasks();
  renderDashboard();
  closeCreateTaskModal();

  // Sync with SQL backend
  try {
    await fetch(`${API_BASE}/tasks`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: newTask.id,
        title: newTask.title,
        description: newTask.description,
        detailed_instructions: newTask.detailedInstructions,
        banner_url: newTask.bannerUrl,
        category: newTask.category,
        points_reward: newTask.pointsReward,
        deadline: newTask.deadline,
        required_submissions: newTask.requiredSubmissions,
      })
    });
  } catch (_) {}

  alert(`Task "${title}" published into SQL database successfully!`);
}

async function deleteTask(id) {
  if (confirm("Are you sure you want to delete this task?")) {
    tasks = tasks.filter(t => t.id !== id);
    renderTasks();
    renderDashboard();

    try {
      await fetch(`${API_BASE}/tasks/${id}`, { method: 'DELETE' });
    } catch (_) {}
  }
}

// ==============================================================
// EVIDENCE INSPECTOR & APPROVALS (SQL ATOMIC UPDATES)
// ==============================================================
function inspectSubmission(id) {
  const sub = submissions.find(s => s.id === id);
  if (!sub) return;

  currentInspectingSubId = id;

  document.getElementById('evidence-modal-title').innerText = sub.taskTitle;
  document.getElementById('evidence-modal-user').innerText = `Submitted by ${sub.userName} (${sub.userEmail}) • ${sub.submittedAt}`;

  // Text
  const textSec = document.getElementById('evidence-text-section');
  if (sub.textResponse) {
    document.getElementById('evidence-text').innerText = sub.textResponse;
    textSec.classList.remove('hidden');
  } else {
    textSec.classList.add('hidden');
  }

  // Photos
  const photoSec = document.getElementById('evidence-photo-section');
  const photosContainer = document.getElementById('evidence-photos');
  photosContainer.innerHTML = '';
  if (sub.photoUrls && sub.photoUrls.length > 0) {
    sub.photoUrls.forEach(url => {
      const img = document.createElement('img');
      img.src = url;
      img.className = 'w-full h-40 object-cover rounded-xl border border-slate-200';
      photosContainer.appendChild(img);
    });
    photoSec.classList.remove('hidden');
  } else {
    photoSec.classList.add('hidden');
  }

  // GPS
  const gpsSec = document.getElementById('evidence-gps-section');
  if (sub.locationAddress) {
    document.getElementById('evidence-gps-address').innerText = sub.locationAddress;
    gpsSec.classList.remove('hidden');
  } else {
    gpsSec.classList.add('hidden');
  }

  const approveBtn = document.getElementById('btn-modal-approve');
  const rejectBtn = document.getElementById('btn-modal-reject');
  if (sub.status === 'pending') {
    approveBtn.classList.remove('hidden');
    rejectBtn.classList.remove('hidden');
  } else {
    approveBtn.classList.add('hidden');
    rejectBtn.classList.add('hidden');
  }

  document.getElementById('modal-evidence').classList.remove('hidden');
}

function closeEvidenceModal() {
  document.getElementById('modal-evidence').classList.add('hidden');
}

function triggerApproveCurrentSub() {
  if (currentInspectingSubId) {
    approveSubmission(currentInspectingSubId);
    closeEvidenceModal();
  }
}

function triggerRejectCurrentSub() {
  if (currentInspectingSubId) {
    promptRejectSubmission(currentInspectingSubId);
    closeEvidenceModal();
  }
}

async function approveSubmission(id) {
  const sub = submissions.find(s => s.id === id);
  if (!sub) return;

  sub.status = 'approved';

  // Award points to user locally
  const user = users.find(u => u.email === sub.userEmail);
  if (user) {
    user.points += sub.pointsReward;
  }

  renderSubmissions();
  renderDashboard();
  renderUsers();

  // Atomic update in SQL Database
  try {
    await fetch(`${API_BASE}/submissions/${id}/review`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        approve: true,
        reviewed_by: 'System Administrator'
      })
    });
  } catch (_) {}

  alert(`Submission approved! +${sub.pointsReward} points awarded in SQL database to ${sub.userName}.`);
}

async function promptRejectSubmission(id) {
  const reason = prompt("Enter specific feedback or reason for rejecting this submission:", "Evidence photo does not meet quality requirements.");
  if (reason) {
    const sub = submissions.find(s => s.id === id);
    if (sub) {
      sub.status = 'rejected';
      sub.rejectionReason = reason;
      renderSubmissions();
      renderDashboard();

      // Update in SQL Database
      try {
        await fetch(`${API_BASE}/submissions/${id}/review`, {
          method: 'PATCH',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            approve: false,
            rejection_reason: reason,
            reviewed_by: 'System Administrator'
          })
        });
      } catch (_) {}

      alert(`Submission marked as rejected in SQL database. Feedback logged: "${reason}"`);
    }
  }
}

function filterSubmissions(status) {
  document.querySelectorAll('.sub-filter-btn').forEach(btn => {
    btn.className = 'sub-filter-btn px-3 py-1.5 rounded-xl text-xs font-semibold bg-white border border-slate-200 text-slate-600 hover:bg-slate-50';
  });
  event.target.className = 'sub-filter-btn px-3 py-1.5 rounded-xl text-xs font-bold bg-slate-900 text-white';
  renderSubmissions(status);
}

// ==============================================================
// REWARDS MANAGEMENT
// ==============================================================
async function openCreateRewardModal() {
  const title = prompt("Enter Reward Title (e.g. $15 Uber Eats Voucher):");
  if (!title) return;
  const points = parseInt(prompt("Points Cost (e.g. 500):", "500")) || 500;
  const newReward = {
    id: `rew_${Date.now()}`,
    title,
    category: 'Vouchers',
    pointsCost: points,
    stock: 20,
    imageUrl: 'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=600',
  };
  rewards.unshift(newReward);
  renderRewards();

  try {
    await fetch(`${API_BASE}/rewards`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: newReward.id,
        title: newReward.title,
        points_cost: newReward.pointsCost,
        image_url: newReward.imageUrl,
        category: newReward.category,
        stock: newReward.stock,
      })
    });
  } catch (_) {}

  alert("Reward added to SQL database!");
}

function deleteReward(id) {
  if (confirm("Remove reward from catalog?")) {
    rewards = rewards.filter(r => r.id !== id);
    renderRewards();
  }
}

function grantBonusPoints(email) {
  const pts = parseInt(prompt(`Add bonus points for ${email}:`, "100"));
  if (pts) {
    const u = users.find(user => user.email === email);
    if (u) {
      u.points += pts;
      renderUsers();
      alert(`Granted ${pts} bonus points to ${u.name}! Total: ${u.points} pts`);
    }
  }
}

function sendBroadcastNotification() {
  const title = document.getElementById('notif-title').value.trim();
  const body = document.getElementById('notif-body').value.trim();
  if (!title || !body) {
    alert("Please fill in notification title and message body.");
    return;
  }
  alert(`Broadcast push notification queued!\nTitle: ${title}\nBody: ${body}`);
  document.getElementById('notif-title').value = '';
  document.getElementById('notif-body').value = '';
}
