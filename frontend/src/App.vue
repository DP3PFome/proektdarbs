<template>
  <div class="app-shell">
    <header class="topbar">
      <div class="brand-row">
        <div class="brand-mark">CollectorHub</div>
        <nav class="nav-links">
          <a href="#" @click.prevent="selectSection('explore')" :class="{ active: activeSection === 'explore' }">{{ t.explore }}</a>
          <a href="#" @click.prevent="selectSection('trending')" :class="{ active: activeSection === 'trending' }">{{ t.trending }}</a>
          <a href="#" @click.prevent="selectSection('categories')" :class="{ active: activeSection === 'categories' }">{{ t.categories }}</a>
          <a href="#" @click.prevent="selectSection('community')" :class="{ active: activeSection === 'community' }">{{ t.community }}</a>
          <a v-if="isLoggedIn" href="#" @click.prevent="selectSection('mine')" :class="{ active: activeSection === 'mine' }">{{ t.myCollections }}</a>
        </nav>
      </div>

      <div class="actions">
        <div class="lang-switch">
          <button type="button" :class="{ active: locale === 'en' }" @click="locale = 'en'">EN</button>
          <button type="button" :class="{ active: locale === 'lv' }" @click="locale = 'lv'">LV</button>
        </div>
        <button v-if="!isLoggedIn" class="ghost-btn" @click="openAuthModal('login')">{{ t.signIn }}</button>
        <button v-if="!isLoggedIn" class="primary-btn" @click="openAuthModal('register')">{{ t.signUp }}</button>
        <button v-if="isLoggedIn" class="ghost-btn" @click="openProfileModal">{{ t.editProfile }}</button>
        <button v-if="isLoggedIn" class="ghost-btn" @click="signOut">{{ t.signOut }}</button>
      </div>
    </header>

    <main class="page-layout">
      <section class="hero-panel">
        <div class="hero-copy-panel">
          <p class="eyebrow">{{ t.collectorCommunity }}</p>
          <h1>{{ t.heroTitle }}</h1>
          <p class="hero-copy">
            {{ t.heroCopy }}
          </p>

          <div class="search-card">
            <span class="search-icon">🔎</span>
            <input
              v-model="searchQuery"
              type="text"
              :placeholder="t.searchPlaceholder"
            />
          </div>

          <div v-if="isLoggedIn" class="action-buttons">
            <button class="primary-btn" @click="openCollectionModal('create')">{{ t.createCollection }}</button>
          </div>
        </div>

        <div class="hero-stats">
          <div class="stat-card">
            <span>{{ stats.collections }}</span>
            <p>{{ t.collectionsStat }}</p>
          </div>
          <div class="stat-card">
            <span>{{ stats.items }}</span>
            <p>{{ t.itemsStat }}</p>
          </div>
          <div class="stat-card">
            <span>{{ stats.users }}</span>
            <p>{{ t.membersStat }}</p>
          </div>
        </div>
      </section>

      <section class="collections-section">
        <div class="section-title-row">
          <h2>{{ t.popularCollections }}</h2>
          <button class="ghost-btn small" @click="clearFilters">{{ t.viewAll }}</button>
        </div>

        <ul class="card-grid">
          <li v-for="(collection, index) in filteredCollections" :key="collection.id" class="collection-card">
            <div class="card-cover" :style="cardBackground(index)"></div>
            <div class="card-content">
              <div class="card-meta">
                <span class="owner">Collector</span>
                <span class="heart">❤</span>
              </div>
              <h3>{{ collection.title }}</h3>
              <p>{{ collection.description }}</p>
              <div class="card-metrics">
                <span>{{ collection.items_count || 0 }} {{ t.itemsStat }}</span>
                <span>{{ collection.user_id ? ('#' + collection.user_id) : '' }}</span>
              </div>
              <div class="tags">
                <span>Rare</span>
                <span>Vintage</span>
                <span>Favorites</span>
              </div>
              <div class="card-actions">
                <button class="action-btn" @click="viewItems(collection)">{{ t.viewItems }}</button>
                <button v-if="isLoggedIn && collection.user_id === currentUserId" class="action-btn edit" @click="openCollectionModal('edit', collection)">{{ t.editCollection }}</button>
                <button v-if="isLoggedIn && collection.user_id === currentUserId" class="action-btn delete" @click="confirmDeleteCollection(collection)">{{ t.deleteCollection }}</button>
              </div>
            </div>
          </li>
        </ul>
      </section>

      <section class="items-section" v-if="selectedCollectionForItem">
        <div class="section-title-row">
          <div>
            <h2>{{ selectedCollectionForItem.title }}</h2>
            <p class="collection-summary">{{ selectedCollectionForItem.description }}</p>
          </div>
          <div class="section-actions">
            <button class="ghost-btn small" @click="selectedCollectionForItem = null">{{ t.clearItemsView }}</button>
            <button v-if="isLoggedIn && selectedCollectionForItem.user_id === currentUserId" class="primary-btn" @click="openItemModal('create')">{{ t.addItem }}</button>
          </div>
        </div>

        <ul class="item-grid">
          <li v-for="item in items" :key="item.id" class="item-card">
            <img v-if="item.image" :src="imageUrl(item.image)" alt="Item image" />
            <div class="item-card-body">
              <h3>{{ item.name }}</h3>
              <p>{{ item.description }}</p>
              <div class="item-actions">
                <button v-if="isLoggedIn && selectedCollectionForItem.user_id === currentUserId" class="action-btn" @click="openItemModal('edit', item)">{{ t.editItem }}</button>
                <button v-if="isLoggedIn && selectedCollectionForItem.user_id === currentUserId" class="action-btn delete" @click="confirmDeleteItem(item)">{{ t.deleteItem }}</button>
              </div>
            </div>
          </li>
        </ul>
      </section>
    </main>

    <div v-if="showAuthModal" class="modal-overlay">
      <div class="modal-backdrop" @click="closeAuthModal"></div>
      <div class="auth-modal">
        <div class="modal-header">
          <div>
            <p class="eyebrow">{{ authMode === 'login' ? t.signIn : t.createAccount }}</p>
            <h2>{{ authMode === 'login' ? t.welcomeBack : t.getStarted }}</h2>
          </div>
          <button class="close-btn" @click="closeAuthModal">✕</button>
        </div>

        <form @submit.prevent="authMode === 'login' ? loginUser() : registerUser()" class="auth-form">
          <div v-if="authMode === 'login'">
            <label>
              {{ t.email }}
              <input v-model="loginForm.email" type="email" :placeholder="t.emailPlaceholder" required />
            </label>

            <label>
              {{ t.password }}
              <div class="password-input-wrapper">
                <input
                  v-model="loginForm.password"
                  :type="showPassword ? 'text' : 'password'"
                  :placeholder="t.enterPassword"
                  required
                />
                <button type="button" class="eye-button" @click="showPassword = !showPassword">
                  {{ showPassword ? '👁️' : '👁️' }}
                </button>
              </div>
            </label>
          </div>

          <div v-else>
            <label>
              {{ t.name }}
              <input v-model="registerForm.name" type="text" :placeholder="t.namePlaceholder" required />
            </label>
            <label>
              {{ t.email }}
              <input v-model="registerForm.email" type="email" :placeholder="t.emailPlaceholder" required />
            </label>
            <label>
              {{ t.password }}
              <div class="password-row">
                <div class="password-input-wrapper">
                  <input
                    v-model="registerForm.password"
                    :type="showPassword ? 'text' : 'password'"
                    :placeholder="t.createPassword"
                  />
                  <button type="button" class="eye-button" @click="showPassword = !showPassword">
                    {{ showPassword ? '👁️' : '👁️' }}
                  </button>
                </div>
                <button type="button" class="generate-btn" @click="generatePassword">
                  {{ t.generatePassword }}
                </button>
              </div>
              <div class="password-strength" v-if="registerForm.password">
                <span>{{ t.strength }}: {{ passwordStrength.label }}</span>
                <div class="strength-bar">
                  <div class="strength-fill" :class="passwordStrength.level" :style="{ width: passwordStrength.percent + '%' }"></div>
                </div>
              </div>
            </label>
            <label>
              {{ t.confirmPassword }}
              <input
                v-model="registerForm.confirmPassword"
                :type="showPassword ? 'text' : 'password'"
                :placeholder="t.confirmPasswordPlaceholder"
              />
            </label>
          </div>

          <button type="submit" class="primary-btn full-width">
            {{ authMode === 'login' ? t.signIn : t.createAccount }}
          </button>

          <p class="switch-text">
            {{ authMode === 'login' ? t.noAccount : t.alreadyHaveAccount }}
            <a href="#" @click.prevent="setAuthMode(authMode === 'login' ? 'register' : 'login')">
              {{ authMode === 'login' ? t.signUp : t.signIn }}
            </a>
          </p>
        </form>
      </div>
    </div>

    <!-- Collection Modal -->
    <div v-if="showCollectionModal" class="modal-overlay">
      <div class="modal-backdrop" @click="closeCollectionModal"></div>
      <div class="auth-modal">
        <div class="modal-header">
          <div>
            <p class="eyebrow">{{ collectionMode === 'create' ? t.createCollection : t.editCollection }}</p>
            <h2>{{ collectionMode === 'create' ? t.createCollection : t.editCollection }}</h2>
          </div>
          <button class="close-btn" @click="closeCollectionModal">✕</button>
        </div>

        <form @submit.prevent="saveCollection" class="auth-form">
          <label>
            {{ t.collectionTitle }}
            <input v-model="collectionForm.title" type="text" required />
          </label>

          <label>
            {{ t.collectionDescription }}
            <textarea v-model="collectionForm.description" rows="4"></textarea>
          </label>

          <label>
            {{ t.tags }}
            <input v-model="tagInput" @keydown.enter.prevent="addTag" type="text" :placeholder="t.addTagPlaceholder" />
            <div class="tags-display" v-if="collectionForm.tags.length">
              <span v-for="(tag, index) in collectionForm.tags" :key="tag" class="tag-chip">
                {{ tag }}
                <button type="button" @click="removeTag(index)">×</button>
              </span>
            </div>
          </label>

          <button type="submit" class="primary-btn full-width">
            {{ t.saveCollection }}
          </button>
        </form>
      </div>
    </div>

    <!-- Item Modal -->
    <div v-if="showItemModal" class="modal-overlay">
      <div class="modal-backdrop" @click="closeItemModal"></div>
      <div class="auth-modal">
        <div class="modal-header">
          <div>
            <p class="eyebrow">{{ itemMode === 'create' ? t.createItem : t.editItem }}</p>
            <h2>{{ itemMode === 'create' ? t.createItem : t.editItem }}</h2>
          </div>
          <button class="close-btn" @click="closeItemModal">✕</button>
        </div>

        <form @submit.prevent="saveItem" class="auth-form">
          <label>
            {{ t.itemName }}
            <input v-model="itemForm.name" type="text" required />
          </label>

          <label>
            {{ t.itemDescription }}
            <textarea v-model="itemForm.description" rows="4"></textarea>
          </label>

          <label>
            {{ t.itemImage }}
            <input type="file" @change="onImageChange" accept="image/*" />
          </label>

          <button type="submit" class="primary-btn full-width">
            {{ t.saveItem }}
          </button>
        </form>
      </div>
    </div>

    <!-- Profile Modal -->
    <div v-if="showProfileModal" class="modal-overlay">
      <div class="modal-backdrop" @click="closeProfileModal"></div>
      <div class="auth-modal">
        <div class="modal-header">
          <div>
            <p class="eyebrow">{{ t.editProfile }}</p>
            <h2>{{ t.editProfile }}</h2>
          </div>
          <button class="close-btn" @click="closeProfileModal">✕</button>
        </div>

        <form @submit.prevent="saveProfile" class="auth-form">
          <label>
            {{ t.name }}
            <input v-model="profileForm.name" type="text" required />
          </label>

          <label>
            {{ t.email }}
            <input v-model="profileForm.email" type="email" required />
          </label>

          <label>
            {{ t.newPassword }}
            <input v-model="profileForm.password" type="password" />
          </label>

          <label>
            {{ t.confirmNewPassword }}
            <input v-model="profileForm.confirmPassword" type="password" />
          </label>

          <button type="submit" class="primary-btn full-width">
            {{ t.saveProfile }}
          </button>
        </form>
      </div>
    </div>

  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      locale: 'en',
      translations: {
        en: {
          explore: 'Explore',
          trending: 'Trending',
          categories: 'Categories',
          community: 'Community',
          signIn: 'Sign In',
          signUp: 'Sign Up',
          signOut: 'Sign Out',
          collectorCommunity: 'Collector community',
          heroTitle: 'Discover the collections that inspire you.',
          heroCopy: 'Search collections, users, and items from the most passionate collectors around the world.',
          searchPlaceholder: 'Search collections, users, or items...',
          popularCollections: 'Popular Collections',
          viewAll: 'View all',
          collectionsStat: 'Collections',
          itemsStat: 'Items',
          membersStat: 'Members',
          email: 'Email',
          emailPlaceholder: 'your@email.com',
          password: 'Password',
          enterPassword: 'Enter your password',
          name: 'Name',
          namePlaceholder: 'Choose a name',
          createPassword: 'Create a password',
          confirmPassword: 'Confirm Password',
          confirmPasswordPlaceholder: 'Confirm your password',
          generatePassword: 'Generate secure password',
          strength: 'Strength',
          createAccount: 'Create Account',
          noAccount: "Don't have an account?",
          alreadyHaveAccount: 'Already have an account?',
          welcomeBack: 'Welcome back',
          getStarted: 'Get started',
          passwordMismatch: 'Passwords do not match.',
          registrationFailed: 'Registration failed.',
          incorrectEmailPassword: 'Incorrect email or password.',
          accountCreated: 'Account created successfully!',
          generatedPasswordAlert: 'Account created! Your generated password:',
          strengthLabels: ['Too weak', 'Weak', 'Fair', 'Good', 'Strong', 'Very strong'],
          // Collection management
          createCollection: 'Create Collection',
          editCollection: 'Edit Collection',
          collectionTitle: 'Title',
          collectionDescription: 'Description',
          tags: 'Tags',
          addTagPlaceholder: 'Add tag and press Enter',
          tags: 'Tags',
          addTagPlaceholder: 'Add tag and press Enter',
          saveCollection: 'Save Collection',
          deleteCollection: 'Delete Collection',
          confirmDelete: 'Are you sure you want to delete this?',
          cancel: 'Cancel',
          confirm: 'Confirm',
          // Item management
          createItem: 'Create Item',
          editItem: 'Edit Item',
          itemName: 'Name',
          itemDescription: 'Description',
          itemImage: 'Image',
          saveItem: 'Save Item',
          deleteItem: 'Delete Item',
          viewItems: 'View Items',
          addItem: 'Add Item',
          itemsInCollection: 'Items in Collection',
          clearItemsView: 'Back to Collections',
          myCollections: 'My Collections',
          // Profile management
          editProfile: 'Edit Profile',
          currentPassword: 'Current Password',
          newPassword: 'New Password',
          confirmNewPassword: 'Confirm New Password',
          saveProfile: 'Save Profile',
          profileUpdated: 'Profile updated successfully',
          passwordsDoNotMatch: 'Passwords do not match'
        },
        lv: {
          explore: 'Pētniecība',
          trending: 'Tendences',
          categories: 'Kategorijas',
          community: 'Kopiena',
          signIn: 'Pierakstīties',
          signUp: 'Reģistrēties',
          signOut: 'Izrakstīties',
          collectorCommunity: 'Kolekcionāru kopiena',
          heroTitle: 'Atklāj kolekcijas, kas iedvesmo.',
          heroCopy: 'Meklē kolekcijas, lietotājus un priekšmetus no visdedzīgākajiem kolekcionāriem visā pasaulē.',
          searchPlaceholder: 'Meklēt kolekcijas, lietotājus vai priekšmetus...',
          popularCollections: 'Populāras kolekcijas',
          viewAll: 'Skatīt visu',
          collectionsStat: 'Kolekcijas',
          itemsStat: 'Preces',
          membersStat: 'Dalībnieki',
          email: 'E-pasts',
          emailPlaceholder: 'jusu@epasts.com',
          password: 'Parole',
          enterPassword: 'Ievadiet paroli',
          name: 'Vārds',
          namePlaceholder: 'Izvēlieties vārdu',
          createPassword: 'Izveidojiet paroli',
          confirmPassword: 'Apstiprināt paroli',
          confirmPasswordPlaceholder: 'Atkārtoti ievadiet paroli',
          generatePassword: 'Ģenerēt drošu paroli',
          strength: 'Stiprums',
          createAccount: 'Izveidot kontu',
          noAccount: 'Nav konta?',
          alreadyHaveAccount: 'Jau ir konts?',
          welcomeBack: 'Atgriezies',
          getStarted: 'Sāc tagad',
          passwordMismatch: 'Paroles nesakrīt.',
          registrationFailed: 'Reģistrācija neizdevās.',
          incorrectEmailPassword: 'Nepareizs e-pasts vai parole.',
          accountCreated: 'Konts veiksmīgi izveidots!',
          generatedPasswordAlert: 'Konts izveidots! Jūsu ģenerētā parole:',
          strengthLabels: ['Pārāk vāja', 'Vāja', 'Viduvēja', 'Laba', 'Stipra', 'Ļoti stipra'],
          // Collection management
          createCollection: 'Izveidot kolekciju',
          editCollection: 'Rediģēt kolekciju',
          collectionTitle: 'Nosaukums',
          collectionDescription: 'Apraksts',
          tags: 'Tagi',
          addTagPlaceholder: 'Pievienot tagu un nospiest Enter',
          saveCollection: 'Saglabāt kolekciju',
          deleteCollection: 'Dzēst kolekciju',
          confirmDelete: 'Vai tiešām vēlaties dzēst?',
          cancel: 'Atcelt',
          confirm: 'Apstiprināt',
          // Item management
          createItem: 'Izveidot preci',
          editItem: 'Rediģēt preci',
          itemName: 'Nosaukums',
          itemDescription: 'Apraksts',
          itemImage: 'Attēls',
          saveItem: 'Saglabāt preci',
          deleteItem: 'Dzēst preci',
          viewItems: 'Skatīt preces',
          addItem: 'Pievienot preci',
          itemsInCollection: 'Preces kolekcijā',
          clearItemsView: 'Atpakaļ uz kolekcijām',
          myCollections: 'Manas kolekcijas',
          // Profile management
          editProfile: 'Rediģēt profilu',
          currentPassword: 'Pašreizējā parole',
          newPassword: 'Jaunā parole',
          confirmNewPassword: 'Apstiprināt jauno paroli',
          saveProfile: 'Saglabāt profilu',
          profileUpdated: 'Profils atjaunināts veiksmīgi',
          passwordsDoNotMatch: 'Paroles nesakrīt'
        }
      },
      isLoggedIn: false,
      currentUserId: null,
      user: null,
      showAuthModal: false,
      showProfileModal: false,
      authMode: 'login',
      showPassword: false,
      activeSection: 'explore',
      searchQuery: '',
      tagInput: '',

      collections: [],
      stats: {
        collections: 0,
        items: 0,
        users: 0
      },

      // Collection management
      showCollectionModal: false,
      collectionMode: 'create', // 'create' or 'edit'
      selectedCollection: null,
      collectionForm: {
        title: '',
        description: '',
        tags: []
      },

      // Item management
      showItemModal: false,
      itemMode: 'create', // 'create' or 'edit'
      selectedItem: null,
      selectedCollectionForItem: null,
      itemForm: {
        name: '',
        description: '',
        image: null
      },

      // Profile management
      showProfileModal: false,
      profileForm: {
        name: '',
        email: '',
        password: '',
        confirmPassword: ''
      },
      items: [],

      loginForm: {
        email: '',
        password: ''
      },

      registerForm: {
        name: '',
        email: '',
        password: '',
        confirmPassword: ''
      }
    };
  },

  // Profile methods
  openProfileModal() {
    this.profileForm = {
      name: this.user.name,
      email: this.user.email,
      password: '',
      confirmPassword: ''
    };
    this.showProfileModal = true;
  },

  closeProfileModal() {
    this.showProfileModal = false;
    this.profileForm = { name: '', email: '', password: '', confirmPassword: '' };
  },

  async saveProfile() {
    if (this.profileForm.password !== this.profileForm.confirmPassword) {
      alert(this.t.passwordsDoNotMatch);
      return;
    }

    try {
      const data = {
        name: this.profileForm.name,
        email: this.profileForm.email
      };
      if (this.profileForm.password) {
        data.password = this.profileForm.password;
      }

      await axios.put('http://127.0.0.1:8000/api/user/profile', data);
      this.user.name = this.profileForm.name;
      this.user.email = this.profileForm.email;
      alert(this.t.profileUpdated);
      this.closeProfileModal();
    } catch (e) {
      alert('Failed to update profile');
    }
  },

  computed: {
    t() {
      return this.translations[this.locale];
    },
    filteredCollections() {
      let results = this.collections;

      if (this.activeSection === 'trending') {
        results = [...results].slice(0, 4);
      }

      if (this.activeSection === 'categories') {
        const categoryKeywords = ['vintage', 'gaming', 'comics', 'rare', 'classic'];
        const filteredByCategory = results.filter((collection) => {
          const content = `${collection.title} ${collection.description}`.toLowerCase();
          return categoryKeywords.some((keyword) => content.includes(keyword));
        });
        if (filteredByCategory.length) {
          results = filteredByCategory;
        }
      }

      if (this.activeSection === 'community') {
        const communityResults = results.filter((collection) => {
          const content = `${collection.title} ${collection.description}`.toLowerCase();
          return content.includes('collector') || content.includes('community');
        });
        if (communityResults.length) {
          results = communityResults;
        }
      }

      if (this.activeSection === 'mine') {
        results = results.filter((collection) => collection.user_id === this.currentUserId);
      }

      if (this.searchQuery.trim()) {
        const query = this.searchQuery.toLowerCase().trim();
        results = results.filter((collection) => {
          return (
            collection.title.toLowerCase().includes(query) ||
            collection.description.toLowerCase().includes(query)
          );
        });
      }

      return results;
    },
    passwordStrength() {
      const pwd = this.registerForm.password || '';
      if (!pwd) {
        return { label: '', percent: 0, level: 'empty' };
      }
      let score = 0;
      if (pwd.length >= 8) score += 1;
      if (pwd.length >= 12) score += 1;
      if (/[a-z]/.test(pwd)) score += 1;
      if (/[A-Z]/.test(pwd)) score += 1;
      if (/[0-9]/.test(pwd)) score += 1;
      if (/[^A-Za-z0-9]/.test(pwd)) score += 1;
      const labels = this.t.strengthLabels;
      const label = labels[Math.min(score, labels.length - 1)];
      const percent = Math.min(100, Math.round((score / 6) * 100));
      let level = 'very-weak';
      if (score >= 5) level = 'very-strong';
      else if (score === 4) level = 'strong';
      else if (score === 3) level = 'good';
      else if (score === 2) level = 'fair';
      else if (score === 1) level = 'weak';
      return { label, percent, level };
    }
  },
  mounted() {
    this.loadCollections();
    this.loadStats();
    this.restoreAuth();
  },
  methods: {
    async restoreAuth() {
      const token = localStorage.getItem('token');
      if (!token) {
        return;
      }

      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

      try {
        const response = await axios.get('http://127.0.0.1:8000/api/user');
        this.isLoggedIn = true;
        this.currentUserId = response.data.id;
      } catch (e) {
        localStorage.removeItem('token');
        delete axios.defaults.headers.common['Authorization'];
        this.isLoggedIn = false;
        this.currentUserId = null;
      }
    },

    openAuthModal(mode) {
      this.authMode = mode;
      this.showAuthModal = true;
      this.showPassword = false;
    },
    closeAuthModal() {
      this.showAuthModal = false;
      this.loginForm.password = '';
      this.registerForm.password = '';
      this.registerForm.confirmPassword = '';
    },
    setAuthMode(mode) {
      this.authMode = mode;
    },
    selectSection(section) {
      this.activeSection = section;
      this.searchQuery = '';
    },
    clearFilters() {
      this.activeSection = 'explore';
      this.searchQuery = '';
    },
    signOut() {
      this.isLoggedIn = false;
      this.currentUserId = null;
      localStorage.removeItem('token');
      delete axios.defaults.headers.common['Authorization'];
      this.loginForm.password = '';
      this.registerForm.password = '';
      this.registerForm.confirmPassword = '';
      this.activeSection = 'explore';
    },
    cardBackground(index) {
      const palettes = [
        'linear-gradient(135deg, #ff6b6b, #f06595)',
        'linear-gradient(135deg, #5b5fef, #8f8cff)',
        'linear-gradient(135deg, #ff9f1c, #ffbf69)',
        'linear-gradient(135deg, #2ec4b6, #3a86ff)',
        'linear-gradient(135deg, #9b5de5, #f15bb5)'
      ];
      return { background: palettes[index % palettes.length] };
    },
    async loadCollections() {
      try {
        const res = await axios.get('http://127.0.0.1:8000/api/collections');
        this.collections = res.data;
      } catch (e) {
        console.error('Unable to load collections', e);
      }
    },
    async loadStats() {
      try {
        const res = await axios.get('http://127.0.0.1:8000/api/stats');
        this.stats = res.data;
      } catch (e) {
        console.error('Unable to load stats', e);
      }
    },
    async loginUser() {
      try {
        const response = await axios.post('http://127.0.0.1:8000/api/login', this.loginForm);
        this.isLoggedIn = true;
        this.currentUserId = response.data.user.id;
        this.user = response.data.user;
        localStorage.setItem('token', response.data.token);
        axios.defaults.headers.common['Authorization'] = `Bearer ${response.data.token}`;
        this.closeAuthModal();
        this.loadCollections();
      } catch (e) {
        const message = e.response?.data?.message || this.t.incorrectEmailPassword;
        alert(message);
      }
    },
    async registerUser() {
      if (this.registerForm.password && this.registerForm.password !== this.registerForm.confirmPassword) {
        alert(this.t.passwordMismatch);
        return;
      }
      try {
        const response = await axios.post('http://127.0.0.1:8000/api/register', {
          name: this.registerForm.name,
          email: this.registerForm.email,
          password: this.registerForm.password
        });
        const generatedPassword = response.data.password;
        this.isLoggedIn = true;
        this.currentUserId = response.data.user.id;
        this.user = response.data.user;
        localStorage.setItem('token', response.data.token);
        axios.defaults.headers.common['Authorization'] = `Bearer ${response.data.token}`;

        if (generatedPassword) {
          alert(`${this.t.generatedPasswordAlert}\n${generatedPassword}`);
        } else {
          alert(this.t.accountCreated);
        }
        this.closeAuthModal();
        this.loadCollections();
      } catch (e) {
        if (e.response?.data?.errors) {
          alert(Object.values(e.response.data.errors).flat().join('\n'));
        } else {
          alert(this.t.registrationFailed);
        }
      }
    },
    generatePassword() {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{}|;:,./<>?';
      let password = '';
      for (let i = 0; i < 16; i++) {
        password += chars.charAt(Math.floor(Math.random() * chars.length));
      }
      this.registerForm.password = password;
      this.registerForm.confirmPassword = password;
    },

    // Collection management methods
    openCollectionModal(mode, collection = null) {
      this.collectionMode = mode;
      this.selectedCollection = collection;
      if (mode === 'edit' && collection) {
        this.collectionForm.title = collection.title;
        this.collectionForm.description = collection.description;
        this.collectionForm.tags = collection.tags ? collection.tags.map(t => t.name) : [];
      } else {
        this.collectionForm.title = '';
        this.collectionForm.description = '';
        this.collectionForm.tags = [];
      }
      this.tagInput = '';
      this.showCollectionModal = true;
    },

    closeCollectionModal() {
      this.showCollectionModal = false;
      this.collectionForm.title = '';
      this.collectionForm.description = '';
      this.collectionForm.tags = [];
      this.tagInput = '';
      this.selectedCollection = null;
    },

    addTag() {
      if (this.tagInput.trim() && !this.collectionForm.tags.includes(this.tagInput.trim())) {
        this.collectionForm.tags.push(this.tagInput.trim());
        this.tagInput = '';
      }
    },

    removeTag(index) {
      this.collectionForm.tags.splice(index, 1);
    },

    async saveCollection() {
      try {
        if (this.collectionMode === 'create') {
          await axios.post('http://127.0.0.1:8000/api/collections', this.collectionForm);
        } else {
          await axios.put(`http://127.0.0.1:8000/api/collections/${this.selectedCollection.id}`, this.collectionForm);
        }
        this.closeCollectionModal();
        this.loadCollections();
      } catch (e) {
        alert('Failed to save collection');
      }
    },

    confirmDeleteCollection(collection) {
      if (confirm(this.t.confirmDelete)) {
        this.deleteCollection(collection);
      }
    },

    async deleteCollection(collection) {
      try {
        await axios.delete(`http://127.0.0.1:8000/api/collections/${collection.id}`);
        this.loadCollections();
      } catch (e) {
        alert('Failed to delete collection');
      }
    },

    // Item management methods
    viewItems(collection) {
      this.selectedCollectionForItem = collection;
      this.loadItems(collection.id);
      // For now, just show items in console. Later we can add a modal or separate view
      console.log('Items for collection:', collection.title, this.items);
    },

    async loadItems(collectionId) {
      try {
        const res = await axios.get(`http://127.0.0.1:8000/api/items/${collectionId}`);
        this.items = res.data;
      } catch (e) {
        console.error('Unable to load items', e);
      }
    },

    openItemModal(mode, item = null) {
      this.itemMode = mode;
      this.selectedItem = item;
      if (mode === 'edit' && item) {
        this.itemForm.name = item.name;
        this.itemForm.description = item.description;
        this.itemForm.image = null;
      } else {
        this.itemForm.name = '';
        this.itemForm.description = '';
        this.itemForm.image = null;
      }
      this.showItemModal = true;
    },

    closeItemModal() {
      this.showItemModal = false;
      this.itemForm.name = '';
      this.itemForm.description = '';
      this.itemForm.image = null;
      this.selectedItem = null;
    },

    async saveItem() {
      try {
        const formData = new FormData();
        formData.append('name', this.itemForm.name);
        formData.append('description', this.itemForm.description);
        formData.append('collection_id', this.selectedCollectionForItem.id);
        if (this.itemForm.image) {
          formData.append('image', this.itemForm.image);
        }

        if (this.itemMode === 'create') {
          await axios.post('http://127.0.0.1:8000/api/items', formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
          });
        } else {
          await axios.put(`http://127.0.0.1:8000/api/items/${this.selectedItem.id}`, formData, {
            headers: { 'Content-Type': 'multipart/form-data' }
          });
        }
        this.closeItemModal();
        this.loadItems(this.selectedCollectionForItem.id);
      } catch (e) {
        alert('Failed to save item');
      }
    },

    confirmDeleteItem(item) {
      if (confirm(this.t.confirmDelete)) {
        this.deleteItem(item);
      }
    },

    async deleteItem(item) {
      try {
        await axios.delete(`http://127.0.0.1:8000/api/items/${item.id}`);
        this.loadItems(this.selectedCollectionForItem.id);
      } catch (e) {
        alert('Failed to delete item');
      }
    },

    onImageChange(event) {
      this.itemForm.image = event.target.files[0];
    },

    imageUrl(path) {
      return `http://127.0.0.1:8000/storage/${path}`;
    }
  }
};
</script>

<style>
:root {
  color-scheme: dark;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: 'Inter', Arial, sans-serif;
  background: #090b10;
  color: #e7eef9;
}

.app-shell {
  min-height: 100vh;
  background: radial-gradient(circle at top left, rgba(99, 102, 241, 0.18), transparent 28%),
    radial-gradient(circle at bottom right, rgba(16, 185, 129, 0.18), transparent 28%),
    #07090f;
}

.topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 36px;
  gap: 24px;
}

.brand-row {
  display: flex;
  align-items: center;
  gap: 32px;
}

.brand-mark {
  font-size: 1.4rem;
  font-weight: 700;
  letter-spacing: 0.04em;
}

.nav-links {
  display: flex;
  gap: 22px;
}

.nav-links a {
  color: rgba(231, 238, 249, 0.77);
  text-decoration: none;
  transition: color 0.2s ease, opacity 0.2s ease;
}

.nav-links a.active,
.nav-links a:hover {
  color: #ffffff;
  opacity: 1;
}

.nav-links a.active {
  text-decoration: underline;
}

.actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.lang-switch {
  display: flex;
  gap: 8px;
}

.lang-switch button {
  border: 1px solid rgba(255,255,255,0.16);
  background: rgba(255,255,255,0.04);
  color: #eef3ff;
  padding: 8px 12px;
  border-radius: 999px;
  cursor: pointer;
}

.lang-switch button.active {
  background: #eef3ff;
  color: #07090f;
  border-color: transparent;
}

.primary-btn,
.ghost-btn {
  border: none;
  border-radius: 999px;
  padding: 12px 20px;
  cursor: pointer;
  font-weight: 600;
}

.primary-btn {
  background: linear-gradient(135deg, #5b5fef, #3b82f6);
  color: white;
}

.ghost-btn {
  background: rgba(255, 255, 255, 0.06);
  color: white;
}

.ghost-btn.small {
  padding: 10px 18px;
}

.items-section {
  margin-top: 40px;
  padding: 30px 36px;
  background: rgba(255,255,255,0.04);
  border-radius: 24px;
  border: 1px solid rgba(255,255,255,0.08);
}

.section-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.collection-summary {
  margin-top: 8px;
  color: rgba(231, 238, 249, 0.76);
}

.item-grid {
  display: grid;
  gap: 20px;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  margin-top: 24px;
  list-style: none;
  padding: 0;
}

.item-card {
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 24px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.item-card img {
  width: 100%;
  height: 180px;
  object-fit: cover;
}

.item-card-body {
  padding: 20px;
}

.item-card-body h3 {
  margin: 0 0 12px;
}

.item-card-body p {
  margin: 0 0 16px;
  color: rgba(231, 238, 249, 0.78);
  line-height: 1.5;
}

.item-actions {
  display: flex;
  gap: 10px;
}

.password-row {
  display: flex;
  gap: 12px;
  align-items: center;
}

.generate-btn {
  border: 1px solid rgba(255,255,255,0.12);
  background: rgba(255,255,255,0.06);
  color: #eef3ff;
  border-radius: 16px;
  padding: 12px 14px;
  cursor: pointer;
  flex-shrink: 0;
}

.password-strength {
  margin-top: 10px;
  color: #b7c3df;
  font-size: 0.9rem;
}

.strength-bar {
  width: 100%;
  height: 8px;
  background: rgba(255,255,255,0.08);
  border-radius: 999px;
  overflow: hidden;
  margin-top: 8px;
}

.strength-fill {
  height: 100%;
  transition: width 0.2s ease;
}

.strength-fill.very-weak {
  background: #ff4d4f;
}

.strength-fill.weak {
  background: #ff7a45;
}

.strength-fill.fair {
  background: #f6c02f;
}

.strength-fill.good {
  background: #3b82f6;
}

.strength-fill.strong {
  background: #22c55e;
}

.strength-fill.very-strong {
  background: #0ea5e9;
}

.page-layout {
  padding: 0 36px 60px;
}

.hero-panel {
  display: grid;
  grid-template-columns: 1.35fr 0.65fr;
  gap: 28px;
  align-items: center;
  margin: 32px auto 48px;
}

.hero-copy-panel {
  max-width: 720px;
}

.eyebrow {
  color: #7c8db0;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  margin-bottom: 14px;
  font-size: 0.82rem;
}

.hero-panel h1 {
  margin: 0;
  font-size: clamp(2.5rem, 2.4vw, 3.8rem);
  line-height: 1.02;
  max-width: 720px;
}

.hero-copy {
  max-width: 560px;
  margin: 24px 0 0;
  color: #b7c3df;
  line-height: 1.8;
}

.search-card {
  margin-top: 28px;
  display: flex;
  align-items: center;
  gap: 12px;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 18px;
  padding: 14px 18px;
  max-width: 560px;
}

.search-card input {
  width: 100%;
  border: none;
  outline: none;
  background: transparent;
  color: #eef3ff;
  font-size: 1rem;
}

.search-icon {
  font-size: 1rem;
  color: #7c8db0;
}

.hero-stats {
  display: grid;
  gap: 18px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.07);
  border-radius: 24px;
  padding: 22px;
  min-height: 130px;
}

.stat-card span {
  display: block;
  font-size: 2rem;
  font-weight: 700;
}

.stat-card p {
  margin: 12px 0 0;
  color: #a0b0d4;
}

.collections-section {
  max-width: 1240px;
  margin: 0 auto;
}

.section-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.collections-section h2 {
  margin: 0;
  font-size: 1.8rem;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 22px;
  list-style: none;
  padding: 0;
  margin: 0;
}

.collection-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 28px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  min-height: 360px;
}

.card-cover {
  min-height: 200px;
  background-size: cover;
  background-position: center;
}

.card-content {
  padding: 22px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.card-meta {
  display: flex;
  justify-content: space-between;
  color: #a0b0d4;
  font-size: 0.95rem;
}

.card-metrics {
  display: flex;
  gap: 12px;
  color: #c9d5ef;
  font-size: 0.9rem;
  margin-top: 6px;
}

.card-content h3 {
  margin: 0;
  font-size: 1.25rem;
}

.card-content p {
  margin: 0;
  line-height: 1.7;
  color: #c9d5ef;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tags span {
  background: rgba(255, 255, 255, 0.08);
  color: #e2eafc;
  padding: 8px 12px;
  border-radius: 999px;
  font-size: 0.82rem;
}

.tags-display {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 8px;
}

.tag-chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: rgba(99, 102, 241, 0.2);
  color: #c7d2fe;
  padding: 6px 10px;
  border-radius: 16px;
  font-size: 0.85rem;
  border: 1px solid rgba(99, 102, 241, 0.3);
}

.tag-chip button {
  border: none;
  background: transparent;
  color: #c7d2fe;
  cursor: pointer;
  font-size: 16px;
  line-height: 1;
  padding: 0;
  margin-left: 4px;
}

.tag-chip button:hover {
  color: #ffffff;
}

.modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 50;
  display: grid;
  place-items: center;
}

.modal-backdrop {
  position: absolute;
  inset: 0;
  background: rgba(7, 8, 14, 0.78);
}

.auth-modal {
  position: relative;
  width: min(560px, calc(100% - 40px));
  background: #0f1220;
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 28px;
  padding: 32px;
  z-index: 1;
  box-shadow: 0 28px 80px rgba(0, 0, 0, 0.35);
  max-height: min(90vh, 860px);
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

.modal-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 26px;
}

.close-btn {
  border: none;
  background: rgba(255, 255, 255, 0.06);
  color: #f7fafc;
  width: 42px;
  height: 42px;
  border-radius: 14px;
  cursor: pointer;
}

.auth-form label {
  display: block;
  color: #cad6f5;
  margin-bottom: 16px;
  font-size: 0.95rem;
}

.auth-form input {
  width: 100%;
  margin-top: 10px;
  padding: 16px 18px;
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.08);
  background: rgba(255, 255, 255, 0.03);
  color: #eef3ff;
  outline: none;
  font-size: 1rem;
  min-height: 54px;
}

.full-width {
  width: 100%;
}

.auth-form button.primary-btn {
  margin-top: 14px;
}

.switch-text {
  margin: 18px 0 0;
  color: #8aa4d0;
  font-size: 0.94rem;
}

.switch-text a {
  color: #ffffff;
  text-decoration: none;
  font-weight: 600;
  margin-left: 6px;
}

.password-input-wrapper {
  position: relative;
}

.password-input-wrapper input {
  width: 100%;
  padding-right: 48px;
}

.password-row {
  display: grid;
  gap: 12px;
}

.password-row .generate-btn {
  width: 100%;
}

.eye-button {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  border: none;
  background: transparent;
  color: #b6c3f1;
  cursor: pointer;
  font-size: 18px;
}

@media (max-width: 920px) {
  .hero-panel {
    grid-template-columns: 1fr;
  }

  .topbar {
    flex-direction: column;
    align-items: flex-start;
  }

  .brand-row {
    flex-wrap: wrap;
  }
}

@media (max-width: 680px) {
  .nav-links {
    display: none;
  }

  .page-layout {
    padding: 0 20px 40px;
  }

  .hero-panel {
    margin: 24px auto 36px;
  }

  .auth-modal {
    width: calc(100% - 24px);
    padding: 22px 18px;
    border-radius: 22px;
  }

  .modal-overlay {
    place-items: start;
    overflow-y: auto;
    padding: 20px 0 24px;
  }

  .modal-header {
    flex-direction: column;
    align-items: stretch;
  }

  .auth-form label {
    font-size: 1rem;
  }

  .auth-form input {
    padding: 18px 16px;
    min-height: 58px;
  }

  .password-row {
    grid-template-columns: 1fr;
  }

  .generate-btn {
    width: 100%;
    padding: 14px 18px;
    border-radius: 16px;
  }
}

/* Collection and Item Management Styles */
.action-buttons {
  margin-top: 20px;
  display: flex;
  gap: 12px;
}

.card-actions {
  margin-top: 16px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.action-btn {
  padding: 8px 12px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.06);
  color: #eef3ff;
  border-radius: 8px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: rgba(255, 255, 255, 0.1);
}

.action-btn.edit {
  border-color: #3b82f6;
  color: #3b82f6;
}

.action-btn.edit:hover {
  background: rgba(59, 130, 246, 0.1);
}

.action-btn.delete {
  border-color: #ef4444;
  color: #ef4444;
}

.action-btn.delete:hover {
  background: rgba(239, 68, 68, 0.1);
}

textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
  color: #eef3ff;
  font-family: inherit;
  resize: vertical;
  min-height: 80px;
}

textarea:focus {
  outline: none;
  border-color: #5b5fef;
}

input[type="file"] {
  width: 100%;
  padding: 8px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
  color: #eef3ff;
}

input[type="file"]::file-selector-button {
  background: #5b5fef;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  margin-right: 12px;
}
</style>
