import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import * as Localization from 'expo-localization';
import { I18nManager } from 'react-native';

// Sample translations for the required languages
const resources = {
  en: {
    translation: {
      // Auth screens
      signIn: 'Sign In',
      signUp: 'Sign Up',
      email: 'Email',
      password: 'Password',
      confirmPassword: 'Confirm Password',
      forgotPassword: 'Forgot Password?',
      noAccount: "Don't have an account?",
      hasAccount: 'Already have an account?',
      signInButton: 'Sign In',
      signUpButton: 'Sign Up',
      signOut: 'Sign Out',
      
      // Home screen
      welcome: 'Welcome to KidsPlay',
      homeTitle: 'Home',
      
      // Common
      loading: 'Loading...',
      error: 'Error',
      success: 'Success',
      cancel: 'Cancel',
      ok: 'OK',
      
      // Validation messages
      emailRequired: 'Email is required',
      emailInvalid: 'Please enter a valid email',
      passwordRequired: 'Password is required',
      passwordTooShort: 'Password must be at least 6 characters',
      passwordsMismatch: 'Passwords do not match'
    }
  },
  tr: {
    translation: {
      signIn: 'Giriş Yap',
      signUp: 'Kayıt Ol',
      email: 'E-posta',
      password: 'Şifre',
      confirmPassword: 'Şifreyi Onayla',
      forgotPassword: 'Şifremi Unuttum?',
      noAccount: 'Hesabınız yok mu?',
      hasAccount: 'Zaten hesabınız var mı?',
      signInButton: 'Giriş Yap',
      signUpButton: 'Kayıt Ol',
      signOut: 'Çıkış Yap',
      welcome: 'KidsPlay\'e Hoş Geldiniz',
      homeTitle: 'Ana Sayfa',
      loading: 'Yükleniyor...',
      error: 'Hata',
      success: 'Başarılı',
      cancel: 'İptal',
      ok: 'Tamam',
      emailRequired: 'E-posta gerekli',
      emailInvalid: 'Geçerli bir e-posta girin',
      passwordRequired: 'Şifre gerekli',
      passwordTooShort: 'Şifre en az 6 karakter olmalı',
      passwordsMismatch: 'Şifreler eşleşmiyor'
    }
  },
  fr: {
    translation: {
      signIn: 'Se connecter',
      signUp: "S'inscrire",
      email: 'Email',
      password: 'Mot de passe',
      confirmPassword: 'Confirmer le mot de passe',
      forgotPassword: 'Mot de passe oublié?',
      noAccount: "Vous n'avez pas de compte?",
      hasAccount: 'Vous avez déjà un compte?',
      signInButton: 'Se connecter',
      signUpButton: "S'inscrire",
      signOut: 'Se déconnecter',
      welcome: 'Bienvenue sur KidsPlay',
      homeTitle: 'Accueil',
      loading: 'Chargement...',
      error: 'Erreur',
      success: 'Succès',
      cancel: 'Annuler',
      ok: 'OK',
      emailRequired: 'Email requis',
      emailInvalid: 'Veuillez saisir un email valide',
      passwordRequired: 'Mot de passe requis',
      passwordTooShort: 'Le mot de passe doit contenir au moins 6 caractères',
      passwordsMismatch: 'Les mots de passe ne correspondent pas'
    }
  },
  ar: {
    translation: {
      signIn: 'تسجيل الدخول',
      signUp: 'إنشاء حساب',
      email: 'البريد الإلكتروني',
      password: 'كلمة المرور',
      confirmPassword: 'تأكيد كلمة المرور',
      forgotPassword: 'نسيت كلمة المرور؟',
      noAccount: 'ليس لديك حساب؟',
      hasAccount: 'لديك حساب بالفعل؟',
      signInButton: 'تسجيل الدخول',
      signUpButton: 'إنشاء حساب',
      signOut: 'تسجيل الخروج',
      welcome: 'مرحباً بك في KidsPlay',
      homeTitle: 'الرئيسية',
      loading: 'جاري التحميل...',
      error: 'خطأ',
      success: 'نجح',
      cancel: 'إلغاء',
      ok: 'موافق',
      emailRequired: 'البريد الإلكتروني مطلوب',
      emailInvalid: 'يرجى إدخال بريد إلكتروني صحيح',
      passwordRequired: 'كلمة المرور مطلوبة',
      passwordTooShort: 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
      passwordsMismatch: 'كلمات المرور غير متطابقة'
    }
  },
  ru: {
    translation: {
      signIn: 'Войти',
      signUp: 'Регистрация',
      email: 'Email',
      password: 'Пароль',
      confirmPassword: 'Подтвердите пароль',
      forgotPassword: 'Забыли пароль?',
      noAccount: 'Нет аккаунта?',
      hasAccount: 'Уже есть аккаунт?',
      signInButton: 'Войти',
      signUpButton: 'Зарегистрироваться',
      signOut: 'Выйти',
      welcome: 'Добро пожаловать в KidsPlay',
      homeTitle: 'Главная',
      loading: 'Загрузка...',
      error: 'Ошибка',
      success: 'Успех',
      cancel: 'Отмена',
      ok: 'ОК',
      emailRequired: 'Email обязателен',
      emailInvalid: 'Введите действительный email',
      passwordRequired: 'Пароль обязателен',
      passwordTooShort: 'Пароль должен быть не менее 6 символов',
      passwordsMismatch: 'Пароли не совпадают'
    }
  }
};

// Get device locale
const locale = Localization.getLocales()[0];
const languageCode = locale?.languageCode || 'en';

// Check if Arabic and enable RTL
const isRTL = languageCode === 'ar';
if (isRTL) {
  I18nManager.allowRTL(true);
  I18nManager.forceRTL(true);
} else {
  I18nManager.allowRTL(false);
  I18nManager.forceRTL(false);
}

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: languageCode,
    fallbackLng: 'en',
    compatibilityJSON: 'v3',
    
    interpolation: {
      escapeValue: false // React already does escaping
    }
  });

export default i18n;