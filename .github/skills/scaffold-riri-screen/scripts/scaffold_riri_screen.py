import argparse
from pathlib import Path


def build_screen_file(screen_name: str, package_name: str) -> str:
    return f"""package {package_name}

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel

@Composable
fun {screen_name}Screen(
    viewModel: {screen_name}ViewModel = viewModel(),
) {{
    val state by viewModel.uiState.collectAsState()
    {screen_name}Screen(
        state = state,
        onIntent = viewModel::onIntent,
    )
}}

@Composable
fun {screen_name}Screen(
    state: {screen_name}UiState,
    onIntent: ({screen_name}Intent) -> Unit,
) {{
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF1A1A2E))
            .padding(24.dp),
    ) {{
        Text(
            text = state.title,
            style = MaterialTheme.typography.headlineSmall,
            color = Color(0xFFF0F0F0),
        )
        Text(
            text = state.subtitle,
            style = MaterialTheme.typography.bodyLarge,
            color = Color(0xFFF0F0F0),
            modifier = Modifier.padding(top = 12.dp),
        )
    }}
}}

@Preview(showBackground = true)
@Composable
private fun {screen_name}ScreenPreview() {{
    Surface(color = Color(0xFF1A1A2E)) {{
        {screen_name}Screen(
            state = {screen_name}UiState(
                title = "{screen_name}",
                subtitle = "Taglish copy goes here",
            ),
            onIntent = {{ }},
        )
    }}
}}
"""


def build_view_model_file(screen_name: str, package_name: str) -> str:
    return f"""package {package_name}

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow


data class {screen_name}UiState(
    val title: String = "{screen_name}",
    val subtitle: String = "Ready ka na?",
)

sealed interface {screen_name}Intent {{
    data object PrimaryActionTapped : {screen_name}Intent
}}

class {screen_name}ViewModel : ViewModel() {{
    private val _uiState = MutableStateFlow({screen_name}UiState())
    val uiState: StateFlow<{screen_name}UiState> = _uiState.asStateFlow()

    fun onIntent(intent: {screen_name}Intent) {{
        when (intent) {{
            {screen_name}Intent.PrimaryActionTapped -> {{
                // Add state updates when wiring real actions.
            }}
        }}
    }}
}}
"""


def main() -> None:
    parser = argparse.ArgumentParser(description="Scaffold a Riri Compose screen + ViewModel.")
    parser.add_argument("--screen", required=True, help="PascalCase screen name, e.g., ChaosReport")
    parser.add_argument("--package", required=True, help="Kotlin package name")
    parser.add_argument("--output-dir", required=True, help="Output directory for generated files")
    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    screen_path = output_dir / f"{args.screen}Screen.kt"
    view_model_path = output_dir / f"{args.screen}ViewModel.kt"

    screen_path.write_text(build_screen_file(args.screen, args.package), encoding="utf-8")
    view_model_path.write_text(build_view_model_file(args.screen, args.package), encoding="utf-8")

    print(f"Generated: {screen_path}")
    print(f"Generated: {view_model_path}")


if __name__ == "__main__":
    main()
