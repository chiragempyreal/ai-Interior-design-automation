import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/project/screens/create_project_screen.dart';
import '../../features/project/models/project_model.dart';
import '../../features/visualizer/screens/image_input_screen.dart';
import '../../features/quote/screens/quote_review_screen.dart'; // Corrected Import
import '../../features/ai_scope/screens/scope_generator_screen.dart';
import '../../features/ai_scope/screens/scope_details_screen.dart';
import '../../features/ai_scope/models/scope_model.dart';
import '../../features/estimate/screens/estimate_generator_screen.dart';
import '../../features/estimate/screens/estimate_details_screen.dart';
import '../../features/estimate/models/estimate_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // Dashboard
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/create-project',
      builder: (context, state) => const CreateProjectScreen(),
    ),
    GoRoute(
      path: '/image-input',
      builder: (context, state) {
        ProjectModel? project;
        ImageSource? source;
        
        if (state.extra is Map) {
          final extras = state.extra as Map<String, dynamic>;
          project = extras['project'] as ProjectModel?;
          source = extras['source'] as ImageSource?;
        } else if (state.extra is ProjectModel) {
          project = state.extra as ProjectModel;
        }
        
        return ImageInputScreen(project: project, autoPickSource: source); // Passes source
      },
    ),
    GoRoute(
      path: '/generate-scope',
      builder: (context, state) {
        final project = state.extra as ProjectModel;
        return ScopeGeneratorScreen(project: project);
      },
    ),
    GoRoute(
      path: '/scope-details',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ScopeDetailsScreen(
          scope: data['scope'] as ScopeModel,
          project: data['project'] as ProjectModel,
        );
      },
    ),
    GoRoute(
      path: '/generate-estimate',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return EstimateGeneratorScreen(
          project: data['project'] as ProjectModel,
          scope: data['scope'] as ScopeModel,
        );
      },
    ),
    GoRoute(
      path: '/estimate-details',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return EstimateDetailsScreen(
          estimate: data['estimate'] as EstimateModel,
          project: data['project'] as ProjectModel,
        );
      },
    ),
    GoRoute(
      path: '/quote-review', // Changed from /quote
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return QuoteReviewScreen(
          estimate: extras['estimate'] as EstimateModel,
          project: extras['project'] as ProjectModel,
        );
      },
    ),
  ],
);
