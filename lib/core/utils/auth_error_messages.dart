const Map<String, String> supabaseAuthErrorMessagesAr = {
  'anonymous_provider_disabled':
      'تسجيل الدخول المجهول غير مفعل في هذا التطبيق.',
  'bad_code_verifier': 'حدث خطأ في عملية التحقق. يرجى المحاولة مرة أخرى.',
  'bad_json': 'البيانات المرسلة غير صحيحة. يرجى المحاولة مرة أخرى.',
  'bad_jwt': 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.',
  'bad_oauth_callback':
      'حدث خطأ في عملية تسجيل الدخول عبر المزود الخارجي. يرجى المحاولة مرة أخرى.',
  'bad_oauth_state':
      'حدث خطأ في عملية تسجيل الدخول عبر المزود الخارجي. يرجى المحاولة مرة أخرى.',
  'captcha_failed': 'فشل التحقق من كابتشا. يرجى المحاولة مرة أخرى.',
  'conflict': 'يوجد تعارض في البيانات. يرجى المحاولة بعد قليل.',
  'email_address_invalid':
      'البريد الإلكتروني غير صالح. يرجى التأكد من صحة البريد الإلكتروني.',
  'email_address_not_authorized':
      'لا يمكن إرسال بريد لهذا العنوان. يرجى استخدام بريد إلكتروني آخر.',
  'email_conflict_identity_not_deletable':
      'لا يمكن حذف هذا الحساب بسبب تعارض في البيانات.',
  'email_exists':
      'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد إلكتروني آخر أو تسجيل الدخول.',
  'email_not_confirmed':
      'يجب تأكيد البريد الإلكتروني قبل تسجيل الدخول. تحقق من بريدك الإلكتروني واتبع رابط التأكيد.',
  'email_provider_disabled': 'التسجيل عبر البريد الإلكتروني غير مفعل حالياً.',
  'flow_state_expired': 'انتهت مهلة العملية. يرجى إعادة المحاولة.',
  'flow_state_not_found': 'انتهت مهلة العملية. يرجى إعادة المحاولة.',
  'hook_payload_invalid_content_type':
      'حدث خطأ في الخادم. يرجى المحاولة لاحقاً.',
  'hook_payload_over_size_limit':
      'البيانات المرسلة كبيرة جداً. يرجى المحاولة مرة أخرى.',
  'hook_timeout': 'انتهت مهلة الاتصال بالخادم. يرجى المحاولة لاحقاً.',
  'hook_timeout_after_retry':
      'انتهت مهلة الاتصال بالخادم. يرجى المحاولة لاحقاً.',
  'identity_already_exists':
      'هذا الحساب مرتبط بحساب آخر. يرجى استخدام طريقة تسجيل دخول مختلفة.',
  'identity_not_found': 'لم يتم العثور على الحساب. يرجى التحقق من بياناتك.',
  'insufficient_aal':
      'مستوى الأمان غير كافٍ. يرجى تفعيل المصادقة الثنائية من إعدادات الحساب.',
  'invalid_credentials':
      'البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى التحقق من بياناتك.',
  'invite_not_found': 'الدعوة منتهية أو مستخدمة. يرجى طلب دعوة جديدة.',
  'manual_linking_disabled': 'ربط الحسابات يدوياً غير مفعل في هذا التطبيق.',
  'mfa_challenge_expired':
      'انتهت صلاحية رمز المصادقة الثنائية. يرجى طلب رمز جديد.',
  'mfa_factor_name_conflict':
      'اسم عامل المصادقة مستخدم بالفعل. يرجى اختيار اسم آخر.',
  'mfa_factor_not_found':
      'عامل المصادقة غير موجود. يرجى إعادة إعداد المصادقة الثنائية.',
  'mfa_ip_address_mismatch':
      'يجب إكمال عملية المصادقة من نفس الجهاز. يرجى المحاولة مرة أخرى.',
  'mfa_phone_enroll_not_enabled':
      'تفعيل المصادقة عبر الهاتف غير مفعل في هذا التطبيق.',
  'mfa_phone_verify_not_enabled': 'التحقق عبر الهاتف غير مفعل في هذا التطبيق.',
  'mfa_totp_enroll_not_enabled':
      'تفعيل المصادقة عبر التطبيق غير مفعل في هذا التطبيق.',
  'mfa_totp_verify_not_enabled': 'التحقق عبر التطبيق غير مفعل في هذا التطبيق.',
  'mfa_verification_failed':
      'رمز المصادقة الثنائية غير صحيح. يرجى إدخال الرمز الصحيح.',
  'mfa_verification_rejected': 'تم رفض محاولة التحقق. يرجى المحاولة لاحقاً.',
  'mfa_verified_factor_exists':
      'عامل المصادقة موجود بالفعل. لا حاجة لإضافة عامل آخر.',
  'mfa_web_authn_enroll_not_enabled':
      'تفعيل المصادقة عبر WebAuthn غير مفعل في هذا التطبيق.',
  'mfa_web_authn_verify_not_enabled':
      'التحقق عبر WebAuthn غير مفعل في هذا التطبيق.',
  'no_authorization': 'ليس لديك صلاحية للوصول. يرجى تسجيل الدخول.',
  'not_admin': 'ليس لديك صلاحيات المسؤول. يرجى التواصل مع الإدارة.',
  'oauth_provider_not_supported': 'مزود تسجيل الدخول غير مدعوم في هذا التطبيق.',
  'otp_disabled': 'تسجيل الدخول عبر رمز التحقق غير مفعل في هذا التطبيق.',
  'otp_expired': 'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد.',
  'over_email_send_rate_limit':
      'تم إرسال العديد من الرسائل لهذا البريد. يرجى الانتظار لمدة 10 دقائق قبل المحاولة مرة أخرى.',
  'over_request_rate_limit':
      'عدد كبير من المحاولات. يرجى الانتظار لمدة 5 دقائق قبل المحاولة مرة أخرى.',
  'over_sms_send_rate_limit':
      'تم إرسال العديد من الرسائل لهذا الرقم. يرجى الانتظار لمدة 10 دقائق قبل المحاولة مرة أخرى.',
  'phone_exists':
      'رقم الهاتف مستخدم بالفعل. يرجى استخدام رقم آخر أو تسجيل الدخول.',
  'phone_not_confirmed':
      'يجب تأكيد رقم الهاتف قبل تسجيل الدخول. تحقق من رسائل SMS واتبع التعليمات.',
  'phone_provider_disabled': 'التسجيل عبر الهاتف غير مفعل في هذا التطبيق.',
  'provider_disabled': 'مزود الخدمة غير مفعل حالياً. يرجى المحاولة لاحقاً.',
  'provider_email_needs_verification':
      'يجب تفعيل البريد الإلكتروني بعد تسجيل الدخول عبر المزود. تحقق من بريدك الإلكتروني.',
  'reauthentication_needed':
      'يجب إعادة تسجيل الدخول لتغيير كلمة المرور. يرجى إدخال كلمة المرور الحالية.',
  'reauthentication_not_valid':
      'رمز إعادة التحقق غير صحيح. يرجى إدخال الرمز الصحيح.',
  'refresh_token_already_used':
      'تم استخدام رمز التحديث بالفعل. يرجى تسجيل الدخول مرة أخرى.',
  'refresh_token_not_found': 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.',
  'request_timeout':
      'انتهت مهلة الطلب. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
  'same_password':
      'كلمة المرور الجديدة يجب أن تختلف عن كلمة المرور الحالية. يرجى اختيار كلمة مرور مختلفة.',
  'session_expired': 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.',
  'session_not_found': 'لم يتم العثور على الجلسة. يرجى تسجيل الدخول مرة أخرى.',
  'signup_disabled':
      'التسجيل مغلق حالياً. يرجى المحاولة لاحقاً أو التواصل مع الإدارة.',
  'single_identity_not_deletable':
      'لا يمكن حذف الحساب الوحيد. يرجى إنشاء حساب جديد أولاً.',
  'sms_send_failed':
      'فشل إرسال رسالة SMS. يرجى المحاولة لاحقاً أو استخدام طريقة أخرى.',
  'sso_domain_already_exists': 'النطاق مستخدم بالفعل. يرجى استخدام نطاق آخر.',
  'sso_provider_not_found': 'مزود SSO غير موجود. يرجى التحقق من الإعدادات.',
  'too_many_enrolled_mfa_factors':
      'عدد كبير من عوامل المصادقة. يرجى حذف بعض العوامل قبل إضافة عامل جديد.',
  'unexpected_audience': 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
  'unexpected_failure':
      'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً أو التواصل مع الدعم.',
  'user_already_exists':
      'المستخدم موجود بالفعل. يرجى تسجيل الدخول بدلاً من إنشاء حساب جديد.',
  'user_banned': 'تم حظر الحساب. يرجى التواصل مع الدعم لمعرفة السبب.',
  'user_not_found':
      'المستخدم غير موجود. يرجى التحقق من بياناتك أو إنشاء حساب جديد.',
  'user_sso_managed':
      'لا يمكن تعديل بعض بيانات الحساب المرتبط بـ SSO. يرجى التواصل مع الإدارة.',
  'validation_failed':
      'البيانات المدخلة غير صحيحة. يرجى التحقق من جميع الحقول وإعادة المحاولة.',
  'weak_password':
      'كلمة المرور ضعيفة جداً. يجب أن تحتوي على 8 أحرف على الأقل مع مزيج من الأحرف والأرقام والرموز.',
  // ... أضف أو عدل حسب الحاجة
};

String getSupabaseAuthErrorMessageAr(dynamic error) {
  String? code;
  // Try to extract code from error object
  if (error is Exception && error.toString().contains('code:')) {
    // Try to parse code from string
    final match = RegExp(r'code: (\w+)').firstMatch(error.toString());
    if (match != null) code = match.group(1);
  } else if (error is Map && error['code'] != null) {
    code = error['code'];
  } else if (error is String) {
    // fallback: try to match known error codes in the string
    for (final k in supabaseAuthErrorMessagesAr.keys) {
      if (error.contains(k)) {
        code = k;
        break;
      }
    }
  }
  if (code != null && supabaseAuthErrorMessagesAr.containsKey(code)) {
    return supabaseAuthErrorMessagesAr[code]!;
  }
  // fallback: return the error as is, or a generic message
  return 'حدث خطأ أثناء العملية. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى. إذا استمرت المشكلة، يرجى التواصل مع الدعم.';
}
